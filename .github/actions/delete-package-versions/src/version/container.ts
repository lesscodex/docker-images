import {execFile} from 'child_process'
import {RestVersionInfo} from './get-versions'

const MAX_MANIFEST_BYTES = 16 * 1024 * 1024
const REGISTRY = 'ghcr.io'

export async function getLinkedContainerVersionDigests(
  owner: string,
  packageName: string,
  versions: RestVersionInfo[]
): Promise<Set<string>> {
  const protectedDigests = new Set<string>()
  const tags = new Set<string>()

  for (const version of versions) {
    if (!version.tagged) continue
    protectedDigests.add(version.version)
    for (const tag of version.tags) {
      tags.add(tag)
    }
  }

  for (const tag of tags) {
    const ref = imageRef(owner, packageName, tag)
    const manifest = await inspectManifest(ref)
    collectIndexManifestDigests(manifest, protectedDigests)
  }

  console.log(
    `Protected ${protectedDigests.size} linked container version digests`
  )
  return protectedDigests
}

function imageRef(owner: string, packageName: string, tag: string): string {
  return `${REGISTRY}/${owner}/${packageName}:${tag}`
}

async function inspectManifest(ref: string): Promise<unknown> {
  return new Promise((resolve, reject) => {
    execFile(
      'docker',
      ['manifest', 'inspect', ref],
      {encoding: 'utf8', maxBuffer: MAX_MANIFEST_BYTES},
      (error, stdout, stderr) => {
        if (error) {
          reject(
            new Error(
              `docker manifest inspect failed for ${ref}: ${stderr || error.message}`
            )
          )
          return
        }

        try {
          resolve(JSON.parse(stdout))
        } catch (parseError) {
          reject(
            new Error(
              `docker manifest inspect returned invalid JSON for ${ref}: ${parseError}`
            )
          )
        }
      }
    )
  })
}

function collectIndexManifestDigests(
  manifest: unknown,
  protectedDigests: Set<string>
): void {
  if (!isRecord(manifest) || !Array.isArray(manifest.manifests)) return

  for (const descriptor of manifest.manifests) {
    if (!isRecord(descriptor) || typeof descriptor.digest !== 'string') {
      continue
    }
    protectedDigests.add(descriptor.digest)
  }
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null
}
