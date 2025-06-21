import { defineConfig, type DefaultTheme } from 'vitepress'
import versionsConfig from '../../versions.json'

function createVersionDropdown(locale: string): DefaultTheme.NavItemWithLink[] {
  const items = versionsConfig.versions.map(version => ({
    text: version === versionsConfig.latest ? `${version} (latest)` : version,
    link: `/${locale}/${version}/`
  }))
  items.push({
    text: '📋 Changelog',
    link: 'https://github.com/Mad-Pixels/awsretry/blob/main/CHANGELOG.md',
  })
  return items
}

export default defineConfig({
  title: "GoLang AWS-Retry",
  description: "Library for AWS API retries",

  lastUpdated: true,
  cleanUrls: true,
  metaChunk: true,

  locales: {
    en: {
      label: 'English',
      lang: 'en',
      title: 'AWS-Retry',
      description: 'Library for AWS API retrieБиблиотека для повторных попыток (ретраев) при работе с AWS API',
      themeConfig: {
        logo: {
          src: '/madpixels.png',
          alt: 'GoDyno',
          href: `/en/${versionsConfig.latest}/`
        },
        nav: [
          { text: 'Reference', link: `/en/${versionsConfig.latest}/reference/lib` },
          {
            text: "Releases",
            items: createVersionDropdown('en')
          }
        ],
        sidebar: {
          [`/en/${versionsConfig.latest}`]: [
            {
              text: 'Getting Started',
              items: [
                { text: 'Usage', link: `/en/${versionsConfig.latest}/guide/usage` },
              ]
            },
            {
              text: 'Reference', 
              collapsed: true, 
              items: [
                { text: 'Lib', link: `/en/${versionsConfig.latest}/reference/lib` } 
              ]
            }
          ]
        },
        socialLinks: [
          { icon: 'github', link: 'https://github.com/Mad-Pixels/awsretry' }
        ],
        footer: {
          message: 'Released under the MIT License.',
          copyright: 'Copyright © 2025 Mad-Pixels'
        }
      }
    },

    ru: {
      label: 'Русский',
      lang: 'ru',
      title: 'AWS-Retry',
      description: 'Генератор Go кода из схем DynamoDB',
      themeConfig: {
        logo: {
          src: '/madpixels.png',
          alt: 'GoDyno',
          href: `/ru/${versionsConfig.latest}/`
        },
        nav: [
          { text: 'Референс', link: `/ru/${versionsConfig.latest}/reference/lib` },
          {
            text: "Релизы",
            items: createVersionDropdown('ru')
          }
        ],
        sidebar: {
          [`/ru/${versionsConfig.latest}/`]: [
            {
              text: 'Начало работы',
              items: [
                { text: 'Использование', link: `/ru/${versionsConfig.latest}/guide/usage` },
              ]
            },
            {
              text: 'Референс', 
              collapsed: true, 
              items: [
                { text: 'Lib', link: `/ru/${versionsConfig.latest}/reference/lib` } 
              ]
            }
          ]
        },
        socialLinks: [
          { icon: 'github', link: 'https://github.com/Mad-Pixels/go-dyno' }
        ],
        footer: {
          message: 'Выпущено под лицензией MIT.',
          copyright: 'Copyright © 2025 Mad-Pixels'
        }
      }
    },
  },

  sitemap: {
    hostname: 'https://awsretry.madpixels.io/'
  },

  head: [
    ['link', { rel: 'canonical', href: 'https://awsretry.madpixels.io/' }],
    ['link', { rel: 'apple-touch-icon', href: '/logo.png' }],

    ['link', { rel: 'icon', type: 'image/png', sizes: '32x32', href: '/logo.png' }],
    ['link', { rel: 'icon', type: 'image/png', sizes: '16x16', href: '/logo.png' }],

    ['meta', { name: 'theme-color', content: '#646cff' }],
    ['meta', { name: 'viewport', content: 'width=device-width, initial-scale=1.0' }],

    ['meta', { property: 'og:description', content: 'Go library for AWS API retries with exponential backoff and comprehensive error handling.' }],
    ['meta', { property: 'og:title', content: 'AWS-Retry: Golang AWS API retries' }],
    ['meta', { property: 'og:image', content: 'https://awsretry.madpixels.io/logo.png' }],
    ['meta', { property: 'og:url', content: 'https://awsretry.madpixels.io/' }],
    ['meta', { property: 'og:site_name', content: 'AWS-Retry' }],
    ['meta', { property: 'og:type', content: 'website' }],

    ['meta', { name: 'twitter:card', content: 'summary_large_image' }],
    ['meta', { name: 'twitter:title', content: 'AWS-Retry: Golang AWS API retries' }],
    ['meta', { name: 'twitter:description', content: 'Go library for AWS API retries with exponential backoff and comprehensive error handling.' }],
    ['meta', { name: 'twitter:image', content: 'https://awsretry.madpixels.io/logo.png' }],
  ]
})
