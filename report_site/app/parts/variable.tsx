import {
  Box,
  Card,
  CardContent,
  CardHeader,
  Dialog,
  DialogContent,
  DialogTitle,
  IconButton,
  Link,
  ListItemButton,
  ListItemText,
  Stack,
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableRow,
  Typography,
} from '@mui/material'
import type {File, MeasureSource} from '../types'
import {Close} from '@mui/icons-material'
import {useState} from 'react'
import type {Variable} from '../types'
import {FileDisplay} from './file'

export function VariableDisplay({meta, file}: {meta: Variable; file: File}) {
  const [open, setOpen] = useState(false)
  const toggle = () => setOpen(!open)
  const {info, resource} = meta
  return (
    <>
      <ListItemButton onClick={toggle}>
        <ListItemText primary={info.short_name} secondary={info.short_description} />
      </ListItemButton>
      <Dialog open={open} onClose={toggle}>
        <DialogTitle>{info.measure}</DialogTitle>
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
        <DialogContent sx={{pt: 0}}>
          <Stack spacing={2}>
            <Typography variant="h5">{info.long_name}</Typography>
            <Typography variant="body2">
              {info.long_description ? <span dangerouslySetInnerHTML={{__html: info.long_description}} /> : <></>}
            </Typography>
            <Box>
              <Typography variant="h6">Metadata</Typography>
              <Table size="small" aria-label="measure info entries">
                <TableHead>
                  <TableRow sx={{'& .MuiTableCell-head': {fontWeight: 'bold'}}}>
                    <TableCell>Entry</TableCell>
                    <TableCell align="right">Value</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  <TableRow>
                    <TableCell>Category</TableCell>
                    <TableCell align="right">{info.category}</TableCell>
                  </TableRow>
                  <TableRow>
                    <TableCell>Type</TableCell>
                    <TableCell align="right">{info.measure_type}</TableCell>
                  </TableRow>
                  <TableRow>
                    <TableCell>Unit</TableCell>
                    <TableCell align="right">{info.unit}</TableCell>
                  </TableRow>
                </TableBody>
              </Table>
            </Box>
            <Box>
              <Typography variant="h6">File</Typography>
              <Table size="small" aria-label="measure info entries">
                <TableHead>
                  <TableRow sx={{'& .MuiTableCell-head': {fontWeight: 'bold'}}}>
                    <TableCell>Feature</TableCell>
                    <TableCell align="right">Value</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  <TableRow>
                    <TableCell>File</TableCell>
                    <TableCell align="right">
                      <FileDisplay meta={file} />
                    </TableCell>
                  </TableRow>
                  <TableRow>
                    <TableCell>Created</TableCell>
                    <TableCell align="right">{resource.created}</TableCell>
                  </TableRow>
                  <TableRow>
                    <TableCell>Seconds to Build</TableCell>
                    <TableCell align="right">{meta.source_time}</TableCell>
                  </TableRow>
                  <TableRow>
                    <TableCell>Bytes</TableCell>
                    <TableCell align="right">{resource.bytes}</TableCell>
                  </TableRow>
                  <TableRow>
                    <TableCell>Encoding</TableCell>
                    <TableCell align="right">{resource.encoding}</TableCell>
                  </TableRow>
                  <TableRow>
                    <TableCell>MD5</TableCell>
                    <TableCell align="right">{resource.md5}</TableCell>
                  </TableRow>
                  <TableRow>
                    <TableCell>Rows</TableCell>
                    <TableCell align="right">{resource.row_count}</TableCell>
                  </TableRow>
                </TableBody>
              </Table>
            </Box>
            <Box>
              <Typography variant="h6">Summary</Typography>
              <Table size="small" aria-label="measure summary">
                <TableHead>
                  <TableRow sx={{'& .MuiTableCell-head': {fontWeight: 'bold'}}}>
                    <TableCell>Component</TableCell>
                    <TableCell align="right">Value</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  <TableRow>
                    <TableCell>Duplicates</TableCell>
                    <TableCell align="right">{meta.duplicates}</TableCell>
                  </TableRow>
                  <TableRow>
                    <TableCell>Missing</TableCell>
                    <TableCell align="right">{meta.missing}</TableCell>
                  </TableRow>
                  <TableRow>
                    <TableCell>Type</TableCell>
                    <TableCell align="right">{meta.type}</TableCell>
                  </TableRow>
                  {meta.type === 'string' ? (
                    <TableRow>
                      <TableCell>Levels</TableCell>
                      <TableCell align="right">{Object.keys(meta.table).length}</TableCell>
                    </TableRow>
                  ) : (
                    <>
                      <TableRow>
                        <TableCell>Min</TableCell>
                        <TableCell align="right">{meta.min.toFixed(2)}</TableCell>
                      </TableRow>
                      <TableRow>
                        <TableCell>Mean</TableCell>
                        <TableCell align="right">{meta.mean.toFixed(2)}</TableCell>
                      </TableRow>
                      <TableRow>
                        <TableCell>Standard Deviation</TableCell>
                        <TableCell align="right">{meta.sd.toFixed(2)}</TableCell>
                      </TableRow>
                      <TableRow>
                        <TableCell>Max</TableCell>
                        <TableCell align="right">{meta.max.toFixed(2)}</TableCell>
                      </TableRow>
                    </>
                  )}
                </TableBody>
              </Table>
            </Box>
            {info.sources && (
              <Box>
                <Typography variant="h6">Sources</Typography>
                {info.sources.map(s => (
                  <SourceDisplay key={s.name} source={s} />
                ))}
              </Box>
            )}
          </Stack>
        </DialogContent>
      </Dialog>
    </>
  )
}

function SourceDisplay({source}: {source: MeasureSource}) {
  return (
    <Card>
      <CardHeader
        title={source.name}
        subheader={
          <Link href={source.url} rel="noreferrer" target="_blank">
            {source.url.replace('https://', '')}
          </Link>
        }
      />
      {source.location && (
        <CardContent sx={{pt: 0}}>
          <Typography variant="body2">{source.location}</Typography>
          {source.location_url && (
            <Link variant="body2" href={source.location_url} rel="noreferrer" target="_blank">
              {source.location_url.replace('https://', '')}
            </Link>
          )}
        </CardContent>
      )}
    </Card>
  )
}
