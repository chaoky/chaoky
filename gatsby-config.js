module.exports = {
  pathPrefix: "/lordie",
  siteMetadata: {
    title: `lordie`,
    author: {
      name: `lordie`,
      summary: `web dev`,
    },
    description: `a personal blog :)`,
    siteUrl: `https://lordie.moe`,
    social: {
      twitter: `lordie_e`,
    },
    defaultImage: `content/book_icon.png`,
  },
  plugins: [
    {
      resolve: `gatsby-source-filesystem`,
      options: {
        path: `${__dirname}/content/org`,
        name: `org`,
      },
    },
    `gatsby-transformer-orga`,
    `gatsby-transformer-sharp`,
    `gatsby-plugin-sharp`,
    {
      resolve: `gatsby-plugin-google-analytics`,
      options: {
        trackingId: `UA-62251910-1`,
      },
    },
    {
      resolve: `gatsby-plugin-manifest`,
      options: {
        name: `Lordie's Opinions`,
        short_name: `Lordie`,
        start_url: `/`,
        background_color: `#ffffff`,
        theme_color: `#663399`,
        display: `minimal-ui`,
        icon: `content/book_icon.png`,
      },
    },
    `gatsby-plugin-react-helmet`,
    {
      resolve: `gatsby-plugin-typography`,
      options: {
        pathToConfigModule: `src/typography`,
      },
    },
    // this (optional) plugin enables Progressive Web App + Offline functionality
    // To learn more, visit: https://gatsby.dev/offline
    `gatsby-plugin-offline`,
    "gatsby-plugin-dark-mode",
    `gatsby-plugin-postcss`,
  ],
}
