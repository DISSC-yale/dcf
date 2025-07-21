import type {ReactNode} from 'react'

// report produced by /scripts/build_data.R
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
}
export type File = {
  resource: DataResource
  repo_name: string
  source_time: number
  settings: Settings
  logs: string
  issues: {data?: string[]; measures?: string[]}
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
  full_name?: string
  measure?: string
  measure_type?: string
  unit?: string
  category?: string
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
  name: string
  url: string
  date_accessed?: string
  location?: string
  location_url?: string
}
export type ReferencesParsed = {[index: string]: {reference: Reference; element: HTMLLIElement}}
export type MeasureInfos = {
  [index: string]: MeasureInfo | References
  _references: References
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
)
