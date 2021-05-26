import React, { useState } from "react"
import { Link } from "gatsby"
import { ThemeToggler } from "gatsby-plugin-dark-mode"
import { scale } from "./typography"
import * as svg from "./svgs"

import "./global.css"

export default function ({
  isHome,
  isFeatured,
  children,
}: {
  isHome: boolean
  children: any
  isFeatured: boolean
}) {
  const toggleTheme = (
    <ThemeToggler>
      {({ toggleTheme, theme }) => (
        <button
          aria-label="theme-switch"
          className="leading-none p-1"
          onClick={() => toggleTheme(theme === "dark" ? "light" : "dark")}
        >
          {theme === "dark" ? <svg.Moon /> : <svg.Sun />}
        </button>
      )}
    </ThemeToggler>
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
        className="mt-auto mb-0"
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
      <div className="mt-auto w-1/2 flex justify-evenly">
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
        minHeight: "100vh",
      }}
      className="md:flex-row flex flex-col  my-auto"
    >
      <div className="sideBar">{sideBar}</div>

      <div className="w-full flex-col flex items-center">
        <main className="md:px-32 md:self-start">{children}</main>
        <Footer />
      </div>
    </div>
  )
}

const Footer = () => {
  return (
    <footer className="my-12 text-center mt-auto">
      <a href="https://github.com/chaoky" target="_blank" rel="noreferrer">
        <svg.Code />
        {" copyleft "}
        {new Date().getFullYear()}
      </a>
    </footer>
  )
}
