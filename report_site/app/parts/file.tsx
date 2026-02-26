import {
  Box,
  Dialog,
  DialogContent,
  DialogTitle,
  IconButton,
  List,
  ListItem,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  Stack,
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableRow,
  Typography,
} from '@mui/material'
import {Check, Close, Warning} from '@mui/icons-material'
import {useState} from 'react'
import type {File} from '../types'
import Link from 'next/link'
import {FileLink} from './file_link'

export function FileDisplay({meta}: {meta: File}) {
  const [open, setOpen] = useState(false)
  const toggle = () => setOpen(!open)
  const {resource, issues} = meta
  const {versions} = resource
  const dataIssues =
    issues && issues.data ?
      Array.isArray(issues.data) ?
        issues.data
      : [issues.data]
    : []
  const measureIssues =
    issues && issues.measures ?
      Array.isArray(issues.measures) ?
        issues.measures
      : [issues.measures]
    : []
  const failed = typeof meta.source_time !== 'number'
  const anyIssues = failed || dataIssues.length || measureIssues.length
  const filename = resource.name.replace('./', '')
  return (
    <>
      <ListItemButton onClick={toggle}>
        <ListItemIcon sx={{minWidth: 40}}>
          {failed ?
            <Close color="error" />
          : anyIssues ?
            <Warning color="warning" />
          : <Check color="success" />}
        </ListItemIcon>
        <ListItemText primary={filename} />
      </ListItemButton>
      <Dialog open={open} onClose={toggle}>
        <DialogTitle sx={{wordWrap: 'break-word', pr: 6}}>{filename}</DialogTitle>
        <IconButton
          aria-label="close info"
          onClick={toggle}
          sx={{
            position: 'absolute',
            right: 8,
            top: 12,
          }}
        >
          <Close />
        </IconButton>
        <DialogContent sx={{pt: 0, wordBreak: 'break-word', '& th': {p: 0}, '& td': {verticalAlign: 'top', p: 0.1}}}>
          <Stack spacing={2}>
            <Box>
              <Typography variant="h6">Metadata</Typography>
              <Table size="small" aria-label="measure info entries">
                <TableHead>
                  <TableRow sx={{'& .MuiTableCell-head': {fontWeight: 'bold'}}}>
                    <TableCell>Feature</TableCell>
                    <TableCell align="right">Value</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  <TableRow>
                    <TableCell role="heading">Source Script{meta.process.scripts.length > 1 ? 's' : ''}</TableCell>
                    <TableCell align="right">
                      {meta.process.scripts.map(s => (
                        <p key={s.path}>
                          <FileLink
                            filename={`${meta.settings.data_dir || 'data'}/${meta.process.name}/${s.path}`}
                            meta={meta}
                          />
                        </p>
                      ))}
                    </TableCell>
                  </TableRow>
                  <TableRow>
                    <TableCell role="heading">File</TableCell>
                    <TableCell align="right">
                      <FileLink filename={resource.name} meta={meta} />
                    </TableCell>
                  </TableRow>
                  <TableRow>
                    <TableCell role="heading">Created</TableCell>
                    <TableCell align="right">{resource.created}</TableCell>
                  </TableRow>
                  <TableRow>
                    <TableCell role="heading">Seconds to Build</TableCell>
                    <TableCell align="right">{meta.source_time}</TableCell>
                  </TableRow>
                  <TableRow>
                    <TableCell role="heading">Bytes</TableCell>
                    <TableCell align="right">{resource.bytes}</TableCell>
                  </TableRow>
                  <TableRow>
                    <TableCell role="heading">Encoding</TableCell>
                    <TableCell align="right">{resource.encoding}</TableCell>
                  </TableRow>
                  <TableRow>
                    <TableCell role="heading">MD5</TableCell>
                    <TableCell align="right">{resource.md5}</TableCell>
                  </TableRow>
                  <TableRow>
                    <TableCell role="heading">Rows</TableCell>
                    <TableCell align="right">{resource.row_count}</TableCell>
                  </TableRow>
                </TableBody>
              </Table>
            </Box>
            {meta.variables.length ?
              <Box>
                <Typography variant="h6">Variables</Typography>
                <Box sx={{maxHeight: 300, overflowY: 'auto'}}>{meta.variables}</Box>
              </Box>
            : <></>}
            {dataIssues.length ?
              <Box>
                <Typography variant="h6">Data Issues</Typography>
                <List disablePadding>
                  {dataIssues.map((issue, i) => (
                    <ListItem key={i}>{issue}</ListItem>
                  ))}
                </List>
              </Box>
            : <></>}
            {measureIssues.length ?
              <Box>
                <Typography variant="h6">Measure Issues</Typography>
                <List disablePadding>
                  {measureIssues.map((issue, i) => (
                    <ListItem key={i}>{issue}</ListItem>
                  ))}
                </List>
              </Box>
            : <></>}
            {failed && (
              <Box>
                <Typography variant="h6" color="error">
                  Source Failure
                </Typography>
                <Typography>{meta.logs}</Typography>
              </Box>
            )}
            {versions && versions.hash && (
              <Box>
                <Typography variant="h6">Previous Versions</Typography>
                <Box sx={{maxHeight: 300, overflowY: 'auto'}}>
                  <Table size="small" aria-label="measure info entries">
                    <TableHead>
                      <TableRow sx={{'& .MuiTableCell-head': {fontWeight: 'bold'}}}>
                        <TableCell>Date</TableCell>
                        <TableCell>Message</TableCell>
                        <TableCell>Commit</TableCell>
                      </TableRow>
                    </TableHead>
                    <TableBody>
                      {versions.hash.map((h, i) => {
                        return (
                          <TableRow key={i}>
                            <TableCell width={220}>{versions.date[i]}</TableCell>
                            <TableCell>{versions.message[i]}</TableCell>
                            <TableCell width={60} title={h}>
                              <Link
                                href={`https://raw.githubusercontent.com/${meta.repo_name}/${h}/${filename}`}
                                rel="noreferrer"
                                target="_blank"
                              >
                                {h.substring(0, 6)}
                              </Link>
                            </TableCell>
                          </TableRow>
                        )
                      })}
                    </TableBody>
                  </Table>
                </Box>
              </Box>
            )}
          </Stack>
        </DialogContent>
      </Dialog>
    </>
  )
}
