// Gatsby supports TypeScript natively!
import React from "react"
import { PageProps, Link, graphql } from "gatsby"
import Layout from "./layout"
import SEO from "./seo"
import { rhythm } from "./typography"

const BlogIndex = ({
  data,
  location,
  pageContext,
}: PageProps<Data, PageContext>) => {
  const siteTitle = data.site.siteMetadata.title
  const posts = data.allOrgContent.edges
  const { currentPage, numPages } = pageContext

  const isFirst = currentPage === 1
  const isLast = currentPage === numPages
  const prevPage = currentPage - 1 === 1 ? "/" : `/${currentPage - 1}`
  const nextPage = `/${currentPage + 1}`

  return (
    <Layout isHome={true}>
      <SEO title="All posts" />
      {posts.map(({ node: { slug, metadata } }) => {
        const title = metadata.title || slug
        return (
          <article key={slug}>
            <header>
              <h3
                style={{
                  marginBottom: rhythm(1 / 4),
                }}
              >
                <Link style={{ boxShadow: `none` }} to={slug}>
                  {title}
                </Link>
              </h3>
              <small>{metadata.date}</small>
            </header>
            <section></section>
          </article>
        )
      })}

      <nav>
        <ul
          style={{
            display: `flex`,
            flexWrap: `wrap`,
            justifyContent: `space-between`,
            listStyle: `none`,
            padding: 0,
          }}
        >
          <li>
            {!isFirst && (
              <Link to={prevPage} rel="prev">
                ← Previous Page
              </Link>
            )}
          </li>
          <li>
            {!isLast && (
              <Link to={nextPage} rel="next">
                Next Page →
              </Link>
            )}
          </li>
        </ul>
      </nav>
    </Layout>
  )
}

export default BlogIndex

export const pageQuery = graphql`
  query blogPageQuery {
    site {
      siteMetadata {
        title
      }
    }
    allOrgContent {
      edges {
        node {
          slug
          metadata {
            date(formatString: "MMMM DD, YYYY")
            title
          }
        }
      }
    }
  }
`

type PageContext = {
  currentPage: number
  numPages: number
}
type Data = {
  site: {
    siteMetadata: {
      title: string
    }
  }
  allOrgContent: {
    edges: {
      node: {
        slug: string
        excerpt: string
        metadata: {
          title: string
          date: string
        }
      }
    }[]
  }
}
