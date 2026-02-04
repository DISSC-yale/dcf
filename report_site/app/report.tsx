import {
  Box,
  Button,
  Card,
  CardContent,
  CardHeader,
  IconButton,
  Link,
  Stack,
  Tab,
  Tabs,
  TextField,
  Typography,
  useColorScheme,
} from '@mui/material'
import {ReactNode, useEffect, useState} from 'react'
import type {File, MeasureInfo, MeasureSource, Report, SourceGroups, Variable} from './types'
import {ChevronLeft, DarkMode, LightMode} from '@mui/icons-material'
import {VariableDisplay} from './parts/variable'
import {FileDisplay} from './parts/file'
import {Diagram} from './parts/diagram'
import {Topics} from './parts/topics'

const id_fields = {time: true, geography: true}
const repoPattern = /^[^\/]+\/[^\/]+$/
const tabParamPattern = /tab=[^&]+/
const isDevelopment = process.env.NODE_ENV === 'development'
const tabNames = {variables: true, topics: true, files: true, diagram: true}

function expandSourceInfo(s: string | MeasureSource, sources: {[index: string]: MeasureSource}) {
  if ('string' === typeof s) return s in sources ? sources[s] : {id: s, name: s}
  return s.id && s.id in sources ? {...sources[s.id], ...s} : {...s}
}

export function ReportDisplay() {
  const {mode, setMode} = useColorScheme()
  const [repoInput, setRepoInput] = useState('')
  const [repo, setRepo] = useState('')
  const [failed, setFailed] = useState(false)
  const submitRepo = (repo: string) => {
    setFailed(false)
    setRepo(repo)
  }
  const [tab, setTab] = useState('variables')
  useEffect(() => {
    const params = window.location.search.replace('?', '').split('&')
    const tabParam = params.filter(e => e.startsWith('tab='))
    if (tabParam.length) {
      const specifiedTab = tabParam[0].replace('tab=', '')
      if (specifiedTab in tabNames) {
        setTab(specifiedTab)
      }
    }
    const repo = params.filter(e => e.startsWith('repo='))
    if (repo.length) submitRepo(repo[0].replace('repo=', ''))
  }, [])
  const [search, setSearch] = useState('')
  const [retrieved, setRetrieved] = useState(false)
  const [report, setReport] = useState<{
    report?: Report
    files: {meta: File; display: ReactNode}[]
    variables: {meta: Variable; display: ReactNode}[]
    categories: SourceGroups
  }>({
    files: [],
    variables: [],
    categories: {},
  })
  useEffect(() => {
    if (!repo) return
    fetch(
      isDevelopment ? 'report/report.json.gz' : `https://api.github.com/repos/${repo}/contents/report.json.gz`,
    ).then(async res => {
      if (res.status !== 200) {
        setFailed(true)
        return
      }
      const blob = await (isDevelopment ?
        res.blob()
      : new Blob([
          Uint8Array.from(
            atob((await res.json()).content)
              .split('')
              .map(x => x.charCodeAt(0)),
          ),
        ]))
      const report = (await new Response(
        await blob.stream().pipeThrough(new DecompressionStream('gzip')),
      ).json()) as Report
      const files: {meta: File; display: ReactNode}[] = []
      const variables: {meta: Variable; display: ReactNode}[] = []
      const encountered: {[index: string]: boolean} = {}
      const measures: {[index: string]: MeasureInfo} = {}
      const categories: SourceGroups = {}
      Object.keys(report.metadata).forEach(full_source_name => {
        if (full_source_name.includes('/standard')) {
          const infos = report.metadata[full_source_name].measure_info
          if (infos) Object.keys(infos).forEach(m => (measures[m] = infos[m]))
        }
      })
      Object.keys(report.metadata).forEach(full_source_name => {
        const source_name = full_source_name.split('/')[0]
        const isBundle = full_source_name.includes('/dist')
        const p = report.metadata[full_source_name]
        const sources = (p.measure_info && p.measure_info._sources) || {}
        const sourceEntries: MeasureSource[] = []
        p.resources.forEach(resource => {
          resource.name = `./${'settings' in report ? report.settings.data_dir : 'data'}/${full_source_name}/${
            resource.filename
          }`
          const file = {
            resource,
            repo_name: repo,
            settings: report.settings,
            source_time: report.source_times[source_name],
            logs: report.logs[source_name],
            process: report.processes[source_name],
            issues: source_name in report.issues ? report.issues[source_name][resource.name] : {},
            variables: [],
          } as File
          if (p.measure_info) {
            resource.schema.fields.forEach(f => {
              const rawInfo = p.measure_info[f.name]
              if (rawInfo) {
                const source_id =
                  'source_id' in rawInfo ? (rawInfo.source_id as string)
                  : !('name' in rawInfo) && f.name in measures ? f.name
                  : ''
                const info: MeasureInfo = source_id in measures ? {...measures[source_id], ...rawInfo} : {...rawInfo}
                if (info.sources) {
                  if (isBundle && source_id in measures) {
                    delete info.sources
                  } else {
                    if (!Array.isArray(info.sources)) info.sources = [info.sources]
                    info.sources = info.sources.map(s => {
                      const source = expandSourceInfo(s, sources)
                      sourceEntries.push(source)
                      return source
                    })
                  }
                }
                p.measure_info[f.name] = info
                const meta = {
                  ...f,
                  info,
                  info_string: JSON.stringify(info).toLowerCase(),
                  source_name,
                  source_time: report.source_times[source_name],
                  resource,
                }
                const display = <VariableDisplay key={f.name} meta={meta} file={file} />
                file.variables.push(display)
                if (!(f.name in id_fields) && !(f.name in encountered)) variables.push({meta, display})
                if (info.category) {
                  if (!(info.category in categories)) categories[info.category] = {}
                  const cat = categories[info.category]
                  if (info.subcategory) {
                    if (!(info.subcategory in cat)) cat[info.subcategory] = {}
                    cat[info.subcategory][f.name] = {info, display, file}
                  }
                }
              }
              encountered[f.name] = true
            })
          }
          resource.source = sourceEntries
          files.push({meta: file, display: <FileDisplay key={resource.name} meta={file} />})
        })
      })
      setReport({report: report, files, variables, categories})
      setRetrieved(true)
    })
  }, [repo])
  const isDark = mode === 'dark'
  return (
    <Box sx={{position: 'absolute', top: 0, left: 0, bottom: 0, right: 0, overflow: 'hidden'}}>
      <Card sx={{height: '100%'}}>
        <CardHeader
          sx={{p: 0}}
          title={
            <Stack direction="row" sx={{justifyContent: 'space-between', alignItems: 'center'}}>
              <Button href="/dcf/" rel="noreferrer">
                <ChevronLeft />
                Package Site
              </Button>
              {retrieved ?
                <Tabs
                  value={tab}
                  onChange={(_, tab) => {
                    window.history.replaceState(
                      {},
                      '',
                      window.location.href.replace(tabParamPattern, '') +
                        (window.location.href.includes('tab=') ? ''
                        : window.location.href.includes('?') ? '&'
                        : '?') +
                        'tab=' +
                        tab,
                    )
                    setTab(tab)
                  }}
                >
                  <Tab label="Variables" value="variables" id="variables-tab" aria-controls="variables-panel" />
                  <Tab label="Topics" value="topics" id="topics-tab" aria-controls="topics-panel" />
                  <Tab label="Files" value="files" id="files-tab" aria-controls="files-panel" />
                  <Tab label="Diagram" value="diagram" id="diagram-tab" aria-controls="diagram-panel" />
                </Tabs>
              : <Typography fontSize="1.35em">Data Collection Project</Typography>}
              <Stack direction="row" spacing={2}>
                {retrieved && (
                  <Link
                    href={`https://github.com/${repo.trim()}`}
                    target="_blank"
                    rel="noreferrer"
                    sx={{fontSize: '.7em', textDecoration: 'none', alignSelf: 'center'}}
                  >
                    {repo}
                  </Link>
                )}
                <Button
                  variant="outlined"
                  color="warning"
                  onClick={() => {
                    setRetrieved(false)
                    setFailed(false)
                    setRepo('')
                  }}
                  disabled={!repo}
                >
                  Reset
                </Button>
                <IconButton
                  color="inherit"
                  onClick={() => setMode(isDark ? 'light' : 'dark')}
                  aria-label="toggle dark mode"
                >
                  {isDark ?
                    <LightMode />
                  : <DarkMode />}
                </IconButton>
              </Stack>
            </Stack>
          }
        />
        {retrieved ?
          <CardContent sx={{position: 'absolute', top: 48, bottom: 0, width: '100%', overflow: 'hidden'}}>
            <Box
              role="tabpanel"
              id="topics-panel"
              aria-labelledby="topics-tab"
              hidden={tab !== 'topics'}
              sx={{height: '100%', overflow: 'hidden', pb: 7}}
            >
              <Box sx={{height: '100%', overflowY: 'auto'}}>
                {report.categories ?
                  <Topics sources={report.categories} />
                : <></>}
              </Box>
            </Box>
            <Box
              role="tabpanel"
              id="variables-panel"
              aria-labelledby="variables-tab"
              hidden={tab !== 'variables'}
              sx={{height: '100%', overflow: 'hidden', pb: 7}}
            >
              <TextField
                size="small"
                label="Filter"
                value={search}
                onChange={e => setSearch(e.target.value.toLowerCase())}
                sx={{mt: 1, mb: 1}}
                fullWidth
              ></TextField>
              <Box sx={{height: '100%', overflowY: 'auto'}}>
                {report.variables.filter(m => !search || m.meta.info_string.includes(search)).map(m => m.display)}
              </Box>
            </Box>
            <Box
              role="tabpanel"
              id="files-panel"
              aria-labelledby="files-tab"
              hidden={tab !== 'files'}
              sx={{height: '100%', overflow: 'hidden'}}
            >
              <Box sx={{height: '100%', overflowY: 'auto'}}>{report.files.map(m => m.display)}</Box>
            </Box>
            <Box
              role="tabpanel"
              id="diagram-panel"
              aria-labelledby="diagram-tab"
              hidden={tab !== 'diagram'}
              sx={{height: '100%', overflow: 'hidden', pb: 7}}
            >
              <Box sx={{height: '100%', overflowY: 'auto'}}>
                {report.report ?
                  <Diagram report={report.report} />
                : <></>}
              </Box>
            </Box>
            {report.report ?
              <Typography variant="caption" sx={{position: 'fixed', bottom: 0, left: 5, opacity: 0.8}}>
                Processed {report.report.date}
              </Typography>
            : <></>}
          </CardContent>
        : <>
            <CardContent sx={{display: 'flex', justifyContent: 'center', mt: 5}}>
              <Stack spacing={3} sx={{maxWidth: 500}}>
                <Typography>
                  Enter the name of a GitHub repository containing a Data Collection Project (e.g.,{' '}
                  <code>dissc-yale/pophive_demo</code>)
                </Typography>
                <TextField
                  label="Repository"
                  variant="standard"
                  value={repoInput}
                  onChange={e => {
                    setFailed(false)
                    setRepoInput(e.target.value)
                  }}
                  onKeyDown={k => {
                    if (k.key == 'Enter') submitRepo(repoInput)
                  }}
                  error={failed}
                  helperText={failed ? 'failed to retrieve report' : ''}
                />
                <Button
                  variant="contained"
                  onClick={() => submitRepo(repoInput)}
                  disabled={!repoInput || !repoPattern.test(repoInput)}
                >
                  View Report
                </Button>
              </Stack>
            </CardContent>
          </>
        }
      </Card>
    </Box>
  )
}
