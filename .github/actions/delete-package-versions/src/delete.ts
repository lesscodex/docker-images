/* eslint-disable i18n-text/no-en */

import {Input} from './input'
import {EMPTY, Observable, from, of, throwError} from 'rxjs'
import {reduce, concatMap, map, expand, tap, mergeMap} from 'rxjs/operators'
import {
  deletePackageVersions,
  getLinkedContainerVersionDigests,
  getOldestVersions,
  RestVersionInfo
} from './version'

export const RATE_LIMIT = 100
let totalCount = 0

export function getVersionIds(
  owner: string,
  packageName: string,
  packageType: string,
  numVersions: number,
  page: number,
  token: string
): Observable<RestVersionInfo[]> {
  return getOldestVersions(
    owner,
    packageName,
    packageType,
    numVersions,
    page,
    token
  ).pipe(
    expand(value =>
      value.paginate
        ? getOldestVersions(
            owner,
            packageName,
            packageType,
            numVersions,
            value.page + 1,
            token
          )
        : EMPTY
    ),
    tap(value => (totalCount = totalCount + value.totalCount)),
    reduce((acc, value) => acc.concat(value.versions), [] as RestVersionInfo[])
  )
}

export function finalIds(input: Input): Observable<string[]> {
  if (input.packageVersionIds.length > 0) {
    const toDelete = Math.min(input.packageVersionIds.length, RATE_LIMIT)
    return of(input.packageVersionIds.slice(0, toDelete))
  }
  if (input.hasOldestVersionQueryInfo()) {
    return getVersionIds(
      input.owner,
      input.packageName,
      input.packageType,
      RATE_LIMIT,
      1,
      input.token
    ).pipe(
      mergeMap(value => {
        // we need to delete oldest versions first
        value.sort((a, b) => {
          if (a.created_at === b.created_at) {
            return a.id - b.id
          }
          return (
            new Date(a.created_at).getTime() - new Date(b.created_at).getTime()
          )
        })
        const protectLinked =
          input.packageType.toLowerCase() === 'container' &&
          input.deleteUntaggedVersions === 'true'

        const linked = protectLinked
          ? getLinkedContainerVersionDigests(
              input.owner,
              input.packageName,
              value
            )
          : Promise.resolve(new Set<string>())

        return from(linked).pipe(
          map(digests => versionIds(input, value, protectLinked, digests))
        )
      })
    )
  }
  return throwError(
    "Could not get packageVersionIds. Explicitly specify using the 'package-version-ids' input"
  )
}

function versionIds(
  input: Input,
  versions: RestVersionInfo[],
  protectLinked: boolean,
  linked: Set<string>
): string[] {
  /*
    Here first filter out the versions that are to be ignored.
    Then compute number of versions to delete (toDelete) based on the inputs.
    */
  let value = versions
  value = value.filter(info => !input.ignoreVersions.test(info.version))

  if (input.deleteUntaggedVersions === 'true') {
    value = value.filter(info => !info.tagged)
    if (protectLinked) {
      value = value.filter(info => !linked.has(info.version))
    }
  }

  let toDelete = 0
  if (input.minVersionsToKeep < 0) {
    toDelete = Math.min(
      value.length,
      Math.min(input.numOldVersionsToDelete, RATE_LIMIT)
    )
  } else {
    toDelete = Math.min(value.length - input.minVersionsToKeep, RATE_LIMIT)
  }
  if (toDelete < 0) return []
  return value.map(info => info.id.toString()).slice(0, toDelete)
}

export function deleteVersions(input: Input): Observable<boolean> {
  if (!input.token) {
    return throwError('No token found')
  }

  if (!input.checkInput()) {
    return throwError('Invalid input combination')
  }

  if (input.numOldVersionsToDelete <= 0 && input.minVersionsToKeep < 0) {
    console.log(
      'Number of old versions to delete input is 0 or less, no versions will be deleted'
    )
    return of(true)
  }

  const result = finalIds(input)

  return result.pipe(
    concatMap(ids =>
      deletePackageVersions(
        ids,
        input.owner,
        input.packageName,
        input.packageType,
        input.token
      )
    )
  )
}
