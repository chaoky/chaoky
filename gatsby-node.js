const path = require(`path`)
const { createFilePath } = require(`gatsby-source-filesystem`)

exports.createPages = async ({ graphql, actions }) => {
  const { createPage } = actions
  const documents = await graphql(`
    {
      allOrgContent {
        edges {
          node {
            slug
          }
          next {
            slug
            metadata {
              title
            }
          }
          previous {
            slug
            metadata {
              title
            }
          }
        }
      }
    }
  `)
  if (documents.errors) {
    throw documents.errors
  }

  // Create blog posts pages.
  const posts = documents.data.allOrgContent.edges

  posts.forEach(({ node, previous, next }, index) => {
    createPage({
      path: node.slug,
      component: path.resolve("./src/blog-post.tsx"),
      context: {
        slug: node.slug,
        previous,
        next,
      },
    })
  })

  // Create blog post list pages
  const postsPerPage = 5
  const numPages = Math.ceil(posts.length / postsPerPage)

  Array.from({ length: numPages }).forEach((_, i) => {
    createPage({
      path: i === 0 ? `/` : `/${i + 1}`,
      component: path.resolve("./src/blog-list.tsx"),
      context: {
        limit: postsPerPage,
        skip: i * postsPerPage,
        numPages,
        currentPage: i + 1,
      },
    })
  })
}
