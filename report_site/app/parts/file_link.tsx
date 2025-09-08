import {Link} from '@mui/material'
import type {File} from '../types'

export function FileLink({filename, meta}: {filename: string; meta: File}) {
  const path = filename.replace('./', '')
  return (
    <Link
      href={`https://github.com/${meta.repo_name}/blob/${
        meta.settings && meta.settings.branch ? meta.settings.branch : 'main'
      }/${path}`}
      rel="noreferrer"
      target="_blank"
    >
      {path}
    </Link>
  )
}
