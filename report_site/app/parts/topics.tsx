import {Box, List, ListItemButton, ListItemText, ListSubheader, Typography} from '@mui/material'
import type {SourceGroups} from '../types'
import {useMemo, useState, type ReactElement} from 'react'
import {TopicDisplay} from './topic_display'

const DRAWER_WIDTH = 250
const displayIds: {[index: string]: string} = {}

export function Topics({sources}: {sources: SourceGroups}) {
  const [currentCategory, setCurrentCategory] = useState({category: '', subcategory: ''})
  const items = useMemo(() => {
    const items: ReactElement[] = []
    Object.keys(sources)
      .sort()
      .forEach(category => {
        const categoryGroup = sources[category]
        items.push(
          <List key={category} component="div" disablePadding subheader={<ListSubheader>{category}</ListSubheader>}>
            {Object.keys(categoryGroup)
              .sort()
              .map(subcategory => {
                const subcatId = category + subcategory
                const subcatIndex = 'subcat' + Object.keys(displayIds).length
                displayIds[subcatIndex] = subcatId
                if (!currentCategory.subcategory) setCurrentCategory({category, subcategory})
                return (
                  <ListItemButton
                    selected={currentCategory.category === category && currentCategory.subcategory === subcategory}
                    key={subcatId}
                    onClick={() => {
                      setCurrentCategory({category, subcategory})
                    }}
                  >
                    <ListItemText primary={subcategory}></ListItemText>
                  </ListItemButton>
                )
              })}
          </List>
        )
      })
    return items
  }, [sources, currentCategory])
  const subcat = useMemo(() => {
    if (currentCategory.category in sources) {
      const cat = sources[currentCategory.category]
      if (currentCategory.subcategory in cat) {
        return cat[currentCategory.subcategory]
      }
    }
  }, [currentCategory, sources])
  return (
    <>
      <Box sx={{position: 'absolute', width: DRAWER_WIDTH + 'px'}}>
        <List disablePadding>{items}</List>
      </Box>
      <Box sx={{position: 'absolute', left: DRAWER_WIDTH + 30 + 'px'}}>
        {currentCategory.subcategory ? (
          <>
            <Typography variant="caption">{currentCategory.category + ' > ' + currentCategory.subcategory}</Typography>
            {subcat && <TopicDisplay variables={subcat} />}
          </>
        ) : (
          <Typography>No Subcategories</Typography>
        )}
      </Box>
    </>
  )
}
