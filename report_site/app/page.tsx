'use client'

import {CssBaseline, ThemeProvider, createTheme} from '@mui/material'
import {StrictMode} from 'react'
import {ReportDisplay} from './report'

const theme = createTheme({
  colorSchemes: {
    dark: {palette: {mode: 'dark', primary: {main: '#a5cdff'}}},
    light: {palette: {mode: 'light', primary: {main: '#00356b'}}},
  },
})

export default function Home() {
  return (
    <StrictMode>
      <ThemeProvider theme={theme} defaultMode="dark" noSsr>
        <div suppressHydrationWarning={true}>
          <CssBaseline enableColorScheme />
        </div>
        <ReportDisplay />
      </ThemeProvider>
    </StrictMode>
  )
}
