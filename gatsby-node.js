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
            metadata {
              tags
            }
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

  const postsPerPage = 5

  // Create blog post list pages default (recent first)
  const posts = documents.data.allOrgContent.edges
  let numPages = Math.ceil(posts.length / postsPerPage)

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

  // Create blog post list with only "featured"
  const featured = posts.filter(e => e.node.metadata.tags.includes("Featured"))
  numPages = Math.ceil(featured.length / postsPerPage)

  Array.from({ length: numPages }).forEach((_, i) => {
    createPage({
      path: i === 0 ? `/featured` : `/featured${i + 1}`,
      component: path.resolve("./src/blog-list.tsx"),
      context: {
        limit: postsPerPage,
        skip: i * postsPerPage,
        numPages,
        currentPage: i + 1,
        tags: ["Featured"],
      },
    })
  })

  // Create blog posts pages.
  posts.forEach(({ node, previous, next }, index) => {
    createPage({
      path: node.slug,
      component: path.resolve("./src/blog-post.tsx"),
      context: {
        slug: node.slug,
        tags: node.metadata.tags,
        previous,
        next,
      },
    })
  })
}
