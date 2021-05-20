import React from "react"
import { Link, graphql } from "gatsby"

import Layout from "./layout"
import SEO from "./seo"
import { rhythm, scale } from "./typography"

const BlogPostTemplate = ({ data, pageContext, location }) => {
  const post = data.orgContent
  // const siteTitle = data.site.siteMetadata.title
  const { previous, next } = pageContext

  return (
    <Layout isHome={false}>
      <SEO
        title={post.metadata.title}
        description={post.metadata.title || post.excerpt}
      />
      <article>
        <header>
          <h1
            style={{
              marginBottom: 0,
            }}
          >
            {post.metadata.title}
          </h1>
          <p
            style={{
              ...scale(-1 / 5),
              display: `block`,
              marginBottom: rhythm(1),
            }}
          >
            {post.metadata.date}
          </p>
        </header>
        <section dangerouslySetInnerHTML={{ __html: post.html }} />
        <hr
          style={{
            marginBottom: rhythm(1),
          }}
        />
      </article>

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
            {previous && (
              <Link to={previous.slug} rel="prev">
                ← {previous.metadata.title}
              </Link>
            )}
          </li>
          <li>
            {next && (
              <Link to={next.slug} rel="next">
                {next.metadata.title} →
              </Link>
            )}
          </li>
        </ul>
      </nav>
    </Layout>
  )
}

export default BlogPostTemplate

export const pageQuery = graphql`
  query BlogPostBySlug($slug: String!) {
    site {
      siteMetadata {
        title
      }
    }
    orgContent(slug: { eq: $slug }) {
      html
      metadata {
        title
        date
      }
    }
  }
`
