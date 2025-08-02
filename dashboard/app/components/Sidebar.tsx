import Link from "next/link";
import React from "react";
import { ImExit } from "react-icons/im";
import { IoIosHome } from "react-icons/io";
import { IoCreate } from "react-icons/io5";

function Sidebar() {
  return (
    <div
      id="hs-sidebar-collapsible-group"
      className="border border-1 h-dvh max-h-dvh rounded-r-xl shadow-2xl border-gray-300 fixed w-60 bg-gray-600"
      role="dialog"
      tabIndex={1}
      aria-label="Sidebar"
    >
      <div className="relative flex flex-col h-full max-h-full ">
        <header className=" p-4 flex justify-between items-center gap-x-2">
          <Link
            className="flex-none font-semibold text-xl text-white focus:outline-hidden focus:opacity-80 dark:text-white "
            href="/"
            aria-label="Brand"
          >
            MangaBal
          </Link>
        </header>

        <nav className="h-full overflow-y-auto [&::-webkit-scrollbar]:w-2 [&::-webkit-scrollbar-thumb]:rounded-full [&::-webkit-scrollbar-track]:bg-gray-100 [&::-webkit-scrollbar-thumb]:bg-gray-300 dark:[&::-webkit-scrollbar-track]:bg-neutral-700 dark:[&::-webkit-scrollbar-thumb]:bg-neutral-500">
          <div
            className="hs-accordion-group pb-0 px-2  w-full flex flex-col flex-wrap"
            data-hs-accordion-always-open
          >
            <ul className="space-y-1">
              <li>
                <Link
                  className=" flex items-center gap-x-3.5 py-2 px-2.5 bg-gray-100 text-sm text-gray-800 rounded-lg hover:bg-gray-100 focus:outline-hidden focus:bg-gray-100 dark:bg-neutral-700 dark:hover:bg-neutral-700 dark:focus:bg-neutral-700 dark:text-white"
                  href="/"
                >
                  <IoIosHome className="size-6" />
                  Dashboard
                </Link>
              </li>
            </ul>
            <ul className="space-y-1 mt-1">
              <li>
                <Link
                  className=" flex items-center gap-x-3.5 py-2 px-2.5 text-white"
                  href="/import"
                >
                  <IoCreate className="size-6" />
                  Import
                </Link>
              </li>
            </ul>
            <ul className="space-y-1 mt-1 relative">
              <li>
                <a
                  className=" flex items-center gap-x-3.5 py-2 px-2.5 text-white absolute top-100"
                  href="#"
                >
                  <ImExit className="size-6" />
                  Logout
                </a>
              </li>
            </ul>
          </div>
        </nav>
      </div>
    </div>
  );
}

export default Sidebar;
