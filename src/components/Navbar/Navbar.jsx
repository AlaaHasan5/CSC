"use client"
import Link from 'next/link';
import Button from '../Button/Button';

export default function Navbar() {
  return (
    <nav className="relative flex w-full flex-wrap items-center justify-between bg-zinc-50 py-2 shadow-dark-mild dark:bg-neutral-700 lg:py-4 cursor-pointer">
      <div className="flex w-full flex-wrap items-center justify-between px-3">
        <div className="ms-3">
          <Link className="text-xl font-medium text-black dark:text-white" href="/">CSC</Link>
        </div>
        
        <ol className="list-reset ms-2 flex">
          <li className="text-black/60 transition duration-200 hover:text-black/80">
            <Link href="/tenders">Tenders</Link>
          </li>
          <li>
            <span className="mx-3 text-black/60 dark:text-white/60">
              /
            </span>
          </li>
          <li className="text-black/60 transition duration-200 hover:text-black/80">
            <Link href="/companies">Companies</Link>
          </li>
          <li>
            <span className="mx-3 text-black/60 dark:text-white/60">
              /
            </span>
          </li>
          <li className="text-black/60 transition duration-200 hover:text-black/80">
            <Link href="/materials">Materials</Link>
          </li>
          <li>
            <span className="mx-3 text-black/60 dark:text-white/60">
              /
            </span>
          </li>
          <li className="text-black/60 transition duration-200 hover:text-black/80">
            <Link href="/createtender">Create Tender</Link>
          </li>
          <li>
            <span className="mx-3 text-black/60 dark:text-white/60">
              /
            </span>
          </li>
          <li className="text-black/60 transition duration-200 hover:text-black/80">
            <Link href="/addcompany">Add Company</Link>
          </li>
        </ol>

        <Button/>
      </div>
    </nav>
  )
}