import type {ReactElement, ReactNode} from 'react'

// report produced by dcf::dcf_build()
export type Report = {
  date: string
  settings: Settings
  source_times: {[index: string]: number}
  issues: {
    [index: string]: Issues
  }
  logs: {
    [index: string]: string
  }
  metadata: {[index: string]: DataPackage}
  processes: {[index: string]: Process}
}
export type Script = {
  path: string
  manual: boolean
  frequency: number
  run_time: number
  last_run: string
  last_status: {log: string[]; success: boolean}
}
export type Process =
  | {
      name: string
      type: 'source'
      checked: string
      check_results: {[index: string]: Issues}
      scripts: Script[]
    }
  | {
      name: string
      type: 'bundle'
      checked: string
      check_results: {[index: string]: Issues}
      scripts: Script[]
      source_files: [string] | {[index: string]: string | [string]}
    }
export type File = {
  resource: DataResource
  repo_name: string
  source_time: number
  settings: Settings
  logs: string
  issues: Issues
  process: Process
  variables: ReactNode[]
}
export type Variable = Field & {
  info: MeasureInfo
  info_string: string
  source_name: string
  source_time: number
  resource: DataResource
}
export type Settings = {
  name: string
  data_dir: string
  github_account: string
  repo_name: string
  branch: string
}
export type Issues = {
  [index: string]: {
    data?: string[]
    measures?: string[]
  }
}
export type DataPackage = {
  measure_info: MeasureInfos
  resources: DataResource[]
}
export type MeasureInfo = {
  source_id?: string
  id?: string
  measure_type?: string
  unit?: string
  category?: string
  subcategory?: string
  aggregation_method?: string
  name?: string
  default?: string
  long_name?: string
  short_name?: string
  description?: string
  long_description?: string
  short_description?: string
  levels?: string[]
  sources?: MeasureSource[]
  citations?: string | string[]
  categories?: string[] | MeasureInfos
  variants?: string[] | MeasureInfos
  origin?: string[]
  source_file?: string
}
export type MeasureSource = {
  id: string
  name: string
  url?: string
  date_accessed?: string
  location?: string
  location_url?: string
  description?: string
  organization?: string
  organization_url?: string
  notes?: string[]
}
export type ReferencesParsed = {[index: string]: {reference: Reference; element: HTMLLIElement}}
export type MeasureInfos = {
  [index: string]: MeasureInfo | References | MeasureSource
  _references: References
  _sources: {[index: string]: MeasureSource}
}
export type SourceGroups = {
  [index: string]: {
    [index: string]: {
      [index: string]: {
        info: MeasureInfo
        display: ReactElement
        file: File
      }
    }
  }
}
export type Reference = {
  title: string
  author: string | (string | {family: string; given?: string})[]
  year: string
  journal?: string
  volume?: string
  page?: string
  version?: string
  doi?: string
  url?: string
}
export type References = {[index: string]: Reference}
export type DataResource = {
  bytes: number
  encoding: string
  md5: string
  sha512: string
  format: string
  name: string
  filename: string
  versions: Versions
  source: MeasureSource[]
  ids: [{variable: 'geography'}]
  id_length: number
  time: string
  profile: 'data-resource'
  created: string
  last_modified: string
  row_count: number
  entity_count: number
  schema: {fields: Field[]}
}
export type Versions = {
  author: string[]
  date: string[]
  hash: string[]
  message: string[]
}
export type Field = {
  name: string
  duplicates: number
  time_range: [number, number]
  missing: number
} & (
  | {
      type: 'string'
      table: {[index: string]: number}
    }
  | {
      type: 'float' | 'integer'
      mean: number
      sd: number
      min: number
      max: number
    }
  | {type: 'unknown'}
)
