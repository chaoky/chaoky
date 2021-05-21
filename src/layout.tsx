import React, { useState } from "react"
import { Link } from "gatsby"
import { ThemeToggler } from "gatsby-plugin-dark-mode"
import { scale } from "./typography"
import {
  Sun,
  Moon,
  Home,
  Star,
  Clock,
  GitHub,
  Twitter,
  Steam,
  Linkedin,
  Code,
} from "./svgs"

import "./global.css"

export default function ({
  isHome,
  children,
}: {
  isHome: Boolean
  children: any
}) {
  const [recent, setRecent] = useState(true)
  const toggleTheme = (
    <ThemeToggler>
      {({ toggleTheme, theme }) => (
        <button
          aria-label="theme-switch"
          className="leading-none p-1"
          onClick={() => toggleTheme(theme === "dark" ? "light" : "dark")}
        >
          {theme === "dark" ? <Moon /> : <Sun />}
        </button>
      )}
    </ThemeToggler>
  )

  const toggleFilter = (
    <button onClick={() => setRecent(!recent)}>
      {recent ? <Star /> : <Clock />}
    </button>
  const toggleFilter = isFeatured ? (
    <Link
      style={{
        boxShadow: `none`,
        color: `inherit`,
      }}
      to={`/featured`}
    >
      <Star />
    </Link>
  ) : (
    <Link
      style={{
        boxShadow: `none`,
        color: `inherit`,
      }}
      to={`/`}
    >
      <Clock />
    </Link>
  )

  const homeLink = (
    <Link
      style={{
        boxShadow: `none`,
        color: `inherit`,
      }}
      to={`/`}
    >
      <Home />
    </Link>
  )

  const sideBar = (
    <>
      <h2
        style={{
          ...scale(1),
          marginBottom: 0,
          marginTop: 0,
          fontFamily: `Montserrat, sans-serif`,
        }}
      >
        Leonardo Dias
      </h2>
      <p>Sotware Developer</p>
      <div>
        {toggleTheme}
        {isHome ? toggleFilter : homeLink}
      </div>
      <div>
        <p>work@lordie.moe</p>
        <p>+55 75 9 9963 6587</p>
      </div>
      <div>
        <GitHub />
        <Linkedin />
        <Twitter />
        <Steam />
      </div>
    </>
  )

  return (
    <div
      style={{
        backgroundColor: "var(--bg)",
        color: "var(--textNormal)",
        transition: "color 0.2s ease-out, background 0.2s ease-out",
        minHeight: "100vh",
      }}
    >
      <div className="sidebar">
        <div
          className="md:h-screen p-4 flex flex-col justify-center items-center"
          style={{ minHeight: 200 }}
        >
          {sideBar}
        </div>
      </div>

      <div className="main-content relative">
        <main>{children}</main>
        <Footer />
      </div>
    </div>
  )
}

const Footer = () => {
  return (
    <footer className="my-12 text-center">
      <a href="https://github.com/chaoky" target="_blank" rel="noreferrer">
        <Code />
        {" copyleft "}
        {new Date().getFullYear()}
      </a>
    </footer>
  )
}
