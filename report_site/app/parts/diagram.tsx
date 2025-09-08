import {Box, IconButton, Toolbar, useColorScheme} from '@mui/material'
import type {DataPackage, MeasureSource, Process, Report} from '../types'
import {useEffect, useRef, useState} from 'react'
import mermaid from 'mermaid'
import {YoutubeSearchedFor, ZoomIn, ZoomOut} from '@mui/icons-material'

const url_start = /https?:\/\/(?:www\.)?/
function makeLink(url: string, name: string = '') {
  return `<a href="${url}" target="_blank" rel="noreferrer">${name ? name : url.replace(url_start, '')}</a>`
}

function fileIssueList(issues: {[index: string]: string | string[]}) {
  const items: string[] = []
  Object.values(issues).forEach(issueList => {
    if (typeof issueList === 'string') {
      items.push(`<li><code>${issueList}</code></li>`)
    } else {
      const parts = issueList[0].split(': ')
      if (parts.length === 2) {
        items.push(`<li><code>${parts[0]}: ${issueList.map(i => i.split(': ')[1]).join(', ')}</code></li>`)
      } else {
        issueList.forEach(item => items.push(`<li><code>${item}</code></li>`))
      }
    }
  })
  return '<ul>' + items.join('') + '</ul>'
}

function byType(a: Process, b: Process) {
  return (a.type === 'bundle' ? 1 : 0) - (b.type === 'bundle' ? 1 : 0)
}

const defaultWidth = 60
export function Diagram({report}: {report: Report}) {
  const [containerWidth, setContainerWidth] = useState(defaultWidth)
  const scheme = useColorScheme()
  const diagram = useRef<HTMLDivElement>(null)
  useEffect(() => {
    if (!diagram.current) return
    const settings = report.settings
    const dataDir = (settings.data_dir || 'data') + '/'
    const branch = (settings.branch || 'main') + '/'
    const repo = settings.github_account ? settings.github_account + '/' + settings.repo_name : ''
    const dataUrl = 'https://github.com/' + repo + '/tree/' + branch + dataDir
    const fileUrl = 'https://github.com/' + repo + '/blob/' + branch + dataDir
    const def: string[] = []

    const metas: {[index: string]: DataPackage[]} = {}
    const source_ids: {[index: string]: {info: MeasureSource; id: string; children: string[]}} = {}
    const file_ids: {[index: string]: number} = {}
    const relationships: string[] = []
    let script_id = 0
    let source_id = 0
    let file_id = 0
    Object.keys(report.processes).forEach(name => (report.processes[name].name = name))
    Object.keys(report.metadata).forEach(fullName => {
      const name = fullName.split('/')[0]
      if (!(name in metas)) metas[name] = []
      metas[name].push(report.metadata[fullName])
    })
    Object.values(report.processes)
      .sort(byType)
      .forEach(process => {
        const name = process.name
        def.push(
          'subgraph ' + name + (repo ? `["<strong>${makeLink(dataUrl + name, name)}</strong>"]` : ''),
          'direction LR'
        )
        process.scripts.forEach(script => {
          def.push(
            'script' +
              script_id++ +
              (repo
                ? `["${
                    makeLink(dataUrl + name + '/' + script.path, script.path) +
                    (script.last_run
                      ? `<br /><p style="font-size: .7em">(last ran on ${script.last_run} in ${script.run_time} seconds)</p>`
                      : '') +
                    (!script.last_status.success
                      ? `<br /><span style="font-size: .7em"><strong>failed:</strong> ${(typeof script.last_status
                          .log === 'string'
                          ? script.last_status.log
                          : script.last_status.log.join(' ')
                        ).replaceAll('"', "'")}</span>`
                      : '')
                  }"]`
                : '') +
              ':::' +
              (script.last_status.success ? 'pass' : 'fail')
          )
        })
        const issues = report.issues[name]
        Object.keys(process.check_results).forEach(fullFile => {
          const outDir = process.type === 'bundle' ? 'dist/' : 'standard/'
          if (fullFile.includes(outDir)) {
            const file = fullFile.split(dataDir)[1]
            file_ids[file] = ++file_id
            const fileIssues = issues[fullFile]
            const hasIssues = fileIssues && Object.keys(fileIssues).length
            def.push(
              'file' +
                file_id +
                (repo
                  ? `["${
                      makeLink(fileUrl + file, file.split(process.type === 'bundle' ? 'dist/' : 'standard/')[1]) +
                      (hasIssues ? '<br />' + fileIssueList(fileIssues) : '')
                    }"]`
                  : '') +
                ':::' +
                (hasIssues ? 'warn' : 'pass')
            )
          }
        })
        def.push('end')
        if (process.type === 'bundle') {
          process.source_files.forEach(sourceFile => {
            if (sourceFile in file_ids) {
              relationships.push(`file${file_ids[sourceFile]} --> ${name}`)
            }
          })
        }
      })
    Object.keys(report.metadata).forEach(innerPath => {
      const resources = report.metadata[innerPath].resources
      resources.forEach(resource => {
        const file = resource.name.split(dataDir)[1]
        resource.source.forEach(source => {
          const parentUrl = source.url || ''
          const url = source.location_url || parentUrl
          if (!(parentUrl in source_ids)) {
            source_ids[parentUrl] = {info: source, id: 'source' + ++source_id, children: []}
          }
          if (!(url in source_ids)) {
            source_ids[url] = {info: source, id: 'source' + ++source_id, children: []}
          }
          if (parentUrl !== url) {
            source_ids[parentUrl].children.push(url)
          }
          def.push(
            `${source_ids[url].id}["${
              source.location_url ? makeLink(source.location_url, source.location) : source.name
            }"]`
          )
          relationships.push('  ' + source_ids[url].id + ' --> file' + file_ids[file])
        })
      })
    })
    relationships.sort()
    def.push(...new Set(relationships))
    Object.values(source_ids).forEach(source => {
      const info = source.info
      if (source.children.length) {
        def.push(`subgraph ${source.id}["${makeLink(info.url, info.name)}"]`, 'direction LR')
        source.children.forEach(child => {
          const childInfo = source_ids[child]
          def.push(childInfo.id)
        })
        def.push('end')
      }
    })
    mermaid
      .render(
        'diagram',
        [
          '---',
          'config:',
          `  theme: '${scheme.mode === 'dark' ? 'dark' : 'default'}'`,
          '---',
          'flowchart LR',
          'classDef pass stroke:#66bb6a',
          'classDef warn stroke:#ffa726',
          'classDef fail stroke:#f44336',
          ...def,
        ].join('\n')
      )
      .then(res => {
        requestAnimationFrame(() => {
          ;(diagram.current as HTMLDivElement).innerHTML = res.svg
        })
      })
  }, [report, scheme.mode])
  return (
    <>
      <Toolbar disableGutters sx={{position: 'absolute', right: 35}}>
        <IconButton
          disabled={containerWidth === 10}
          aria-label="zoom out"
          onClick={() => {
            setContainerWidth(containerWidth > 10 ? containerWidth - 10 : 0)
          }}
        >
          <ZoomOut />
        </IconButton>
        <IconButton
          disabled={containerWidth === defaultWidth}
          aria-label="reset"
          onClick={() => {
            setContainerWidth(defaultWidth)
          }}
        >
          <YoutubeSearchedFor />
        </IconButton>
        <IconButton
          disabled={containerWidth === 150}
          aria-label="zoom in"
          onClick={() => {
            setContainerWidth(containerWidth < 150 ? containerWidth + 10 : 150)
          }}
        >
          <ZoomIn />
        </IconButton>
      </Toolbar>
      <Box
        sx={{
          width: containerWidth + '%',
          m: 'auto',
          mt: '64px',
          '& svg': {maxWidth: '9999px !important'},
        }}
        ref={diagram}
      ></Box>
    </>
  )
}
