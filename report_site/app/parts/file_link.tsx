import type {File} from '../types'
import Link from 'next/link'

export function FileLink({filename, meta}: {filename: string; meta: File}) {
  const path = filename.replace('./', '')
  return (
    <Link
      href={`https://github.com/${meta.repo_name}/blob/${meta.settings.branch}/${path}`}
      rel="noreferrer"
      target="_blank"
    >
      {path}
    </Link>
  )
}
