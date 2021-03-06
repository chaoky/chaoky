import React, { useState, useLayoutEffect } from "react"
import { Link } from "gatsby"
import { ThemeToggler } from "gatsby-plugin-dark-mode"
import { scale } from "./typography"
import * as svg from "./svgs"
import "./global.scss"

export default function ({
  isHome,
  isFeatured,
  children,
}: {
  isHome: boolean
  children: any
  isFeatured: boolean
}) {
  const [dark, setDark] = useTheme()

  const toggleTheme = (
    <button
      aria-label="theme-switch"
      className="leading-none p-1"
      onClick={() => {
        setDark(!dark)
      }}
    >
      {dark ? <svg.Moon /> : <svg.Sun />}
    </button>
  )

  const toggleFilter = isFeatured ? (
    <Link style={{ boxShadow: `none`, color: `inherit` }} to={`/featured`}>
      <svg.Star />
    </Link>
  ) : (
    <Link style={{ boxShadow: `none`, color: `inherit` }} to={`/`}>
      <svg.Clock />
    </Link>
  )

  const homeLink = (
    <Link style={{ boxShadow: `none`, color: `inherit` }} to={`/`}>
      <svg.Home />
    </Link>
  )

  const sideBar = (
    <>
      <h1
        style={{
          ...scale(1),
          fontFamily: `Montserrat, sans-serif`,
        }}
        className="mt-auto mb-0 text-center"
      >
        Leonardo Dias
      </h1>
      <p className="m-0">Sotware Developer</p>
      <div className="mt-14">
        {toggleTheme}
        {isHome ? toggleFilter : homeLink}
      </div>
      <div className="mt-5">
        <p className="m-0">work@lordie.moe</p>
        <p className="m-0">+55 75 9 9963 6587</p>
      </div>
      <div className="md:mt-auto mt-8 w-1/2 flex justify-evenly">
        <svg.GitHub />
        <svg.Linkedin />
        <svg.Twitter />
        <svg.Steam />
      </div>
    </>
  )

  return (
    <div
      style={{
        backgroundColor: "var(--bg)",
        color: "var(--textNormal)",
        transition: "color 0.2s ease-out, background 0.2s ease-out",
      }}
      className="md:flex-row flex flex-col my-auto"
    >
      <div className="sideBar">{sideBar}</div>

      <div className="w-full min-h-screen flex-col flex items-center">
        <main className="md:self-start w-full md:px-32 px-14">{children}</main>
        <Footer />
      </div>
    </div>
  )
}

const Footer = () => {
  return (
    <footer className="mb-8 text-center mt-auto">
      <a
        href="https://github.com/chaoky"
        target="_blank"
        rel="noreferrer"
        className="flex items-center gap-2"
      >
        <svg.Code />
        {" copyleft "} {new Date().getFullYear()}
      </a>
    </footer>
  )
}

function useTheme() {
  if (typeof window !== "undefined") {
    const [dark, setDark] = useState(() => {
      switch (window.sessionStorage.getItem("theme")) {
        case "light":
          return false
        case "dark":
          return true
        default:
          return window.matchMedia("(prefers-color-scheme: dark)").matches
      }
    })

    useLayoutEffect(() => {
      const cs = document.body.classList
      if (dark) {
        window.sessionStorage.setItem("theme", "dark")
        cs.add("dark")
      } else {
        window.sessionStorage.setItem("theme", "light")
        cs.remove("dark")
      }
    }, [dark])

    return [dark, setDark]
  }
  return [null, null]
}
