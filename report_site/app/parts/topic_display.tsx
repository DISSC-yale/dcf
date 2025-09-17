import {Box, Divider, Link, List, ListItem, Stack, Typography} from '@mui/material'
import type {File, MeasureInfo, MeasureSource} from '../types'
import {useMemo, type ReactElement} from 'react'

type MeasureBundle = {info: MeasureInfo; display: ReactElement; file: File}

export function TopicDisplay({variables}: {variables: {[index: string]: MeasureBundle}}) {
  const sources = useMemo(() => {
    const sources: {[index: string]: {source: MeasureSource; variables: MeasureBundle[]}} = {}
    Object.keys(variables).forEach(measure => {
      const bundle = variables[measure]
      if (bundle.info.sources) {
        bundle.info.sources.forEach(source => {
          if (!(source.id in sources)) sources[source.id] = {source, variables: []}
          sources[source.id].variables.push(bundle)
        })
      }
    })
    return sources
  }, [variables])
  return (
    <>
      {Object.values(sources).map(({source, variables}, i) => {
        return (
          <Box key={i} sx={{pt: 2}}>
            <Typography variant="h4">{source.name}</Typography>
            {source.url && (
              <Link href={source.url} rel="noreferrer" target="_blank">
                {source.url.replace('https://', '')}
              </Link>
            )}
            {source.organization && (
              <Typography sx={{pt: 1, pb: 1}}>
                Organization:{' '}
                {source.organization_url ? (
                  <Link href={source.organization_url} rel="noreferrer" target="_blank">
                    {source.organization}
                  </Link>
                ) : (
                  source.organization
                )}
              </Typography>
            )}
            <Typography>{source.description}</Typography>
            {source.notes && source.notes.length ? (
              <>
                <Typography variant="h6">Notes:</Typography>
                <List>
                  {source.notes.map((note, i) => (
                    <ListItem key={i}>{note}</ListItem>
                  ))}
                </List>
              </>
            ) : (
              <></>
            )}
            <Divider variant="middle" sx={{p: 1}}></Divider>
            <Typography variant="h6">Variables:</Typography>
            <Stack spacing={1}>{variables.map(v => v.display)}</Stack>
          </Box>
        )
      })}
    </>
  )
}
