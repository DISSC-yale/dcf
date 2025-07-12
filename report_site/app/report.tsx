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
import React, {ReactNode, useEffect, useState} from 'react'
import type {DataResource, Field, MeasureInfo, Report} from './types'
import {ChevronLeft, DarkMode, LightMode} from '@mui/icons-material'
import {VariableDisplay} from './parts/variable'
import {FileDisplay} from './parts/file'

const id_fields = {time: true, geography: true}
const repoPattern = /^[^\/]+\/[^\/]+$/

export type File = {
  resource: DataResource
  repo_name: string
  source_time: number
  logs: string
  issues: {data?: string[]; measures?: string[]}
}
export type Variable = Field & {
  info: MeasureInfo
  info_string: string
  source_name: string
  source_time: number
  resource: DataResource
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
  useEffect(() => {
    const repo = window.location.search
      .replace('?', '')
      .split('&')
      .filter(e => e.startsWith('repo='))
    if (repo.length) submitRepo(repo[0].replace('repo=', ''))
  })
  const [tab, setTab] = useState('variables')
  const [search, setSearch] = useState('')
  const [retrieved, setRetrieved] = useState(false)
  const [report, setReport] = useState<{
    date: string
    files: {meta: File; display: ReactNode}[]
    variables: {meta: Variable; display: ReactNode}[]
  }>({
    date: '2025',
    files: [],
    variables: [],
  })
  useEffect(() => {
    if (!repo) return
    fetch(`https://api.github.com/repos/${repo}/contents/report.json.gz`).then(async res => {
      if (res.status !== 200) {
        setFailed(true)
        setRepo('')
        return
      }
      const blob = await (repo
        ? new Blob([
            Uint8Array.from(
              atob((await res.json()).content)
                .split('')
                .map(x => x.charCodeAt(0))
            ),
          ])
        : res.blob())
      const report = (await new Response(
        await blob.stream().pipeThrough(new DecompressionStream('gzip'))
      ).json()) as Report
      const files: {meta: File; display: ReactNode}[] = []
      const variables: {meta: Variable; display: ReactNode}[] = []
      const encountered: {[index: string]: boolean} = {}
      Object.keys(report.metadata).forEach(source_name => {
        const p = report.metadata[source_name]
        p.resources.forEach(resource => {
          resource.name = `./${'settings' in report ? report.settings.data_dir : 'data'}/${source_name}/standard/${
            resource.filename
          }`
          const file = {
            resource,
            repo_name: repo,
            source_time: report.source_times[source_name],
            logs: report.logs[source_name],
            issues: source_name in report.issues ? report.issues[source_name][resource.name] : {},
          }
          files.push({meta: file, display: <FileDisplay key={resource.name} meta={file} />})
          resource.schema.fields.forEach(f => {
            if (!(f.name in id_fields) && !(f.name in encountered)) {
              encountered[f.name] = true
              const info = p.measure_info[f.name]
              if (info) {
                const meta = {
                  ...f,
                  info,
                  info_string: info ? JSON.stringify(info).toLowerCase() : '',
                  source_name,
                  source_time: report.source_times[source_name],
                  resource,
                }
                variables.push({
                  meta,
                  display: <VariableDisplay key={f.name} meta={meta} />,
                })
              }
            }
          })
        })
      })
      setReport({date: report.date, files, variables})
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
              {retrieved ? (
                <Tabs value={tab} onChange={(_, tab) => setTab(tab)}>
                  <Tab label="Variables" value="variables" id="variables-tab" aria-controls="variables-panel" />
                  <Tab label="Files" value="files" id="files-tab" aria-controls="files-panel" />
                </Tabs>
              ) : (
                <Typography fontSize="1.35em">Data Collection Project</Typography>
              )}
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
                  {isDark ? <LightMode /> : <DarkMode />}
                </IconButton>
              </Stack>
            </Stack>
          }
        />
        {retrieved ? (
          <CardContent sx={{position: 'absolute', top: 48, bottom: 0, width: '100%', overflow: 'hidden'}}>
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
            <Box role="tabpanel" id="files-panel" aria-labelledby="files-tab" hidden={tab !== 'files'}>
              {report.files.map(m => m.display)}
            </Box>
            <Typography variant="caption" sx={{position: 'fixed', bottom: 0, left: 5, opacity: 0.8}}>
              Processed {report.date}
            </Typography>
          </CardContent>
        ) : (
          <>
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
        )}
      </Card>
    </Box>
  )
}
