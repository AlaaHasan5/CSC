import Link from 'next/link';

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

        <div className="flex items-center">
          <button type="button" className="me-3 rounded bg-black text-white py-1.5 px-4">
            Connect Metamask
          </button>
        </div>
      </div>
    </nav>
  )
}




//         <ol className="list-reset ">

//         </ol>

//         <ol className="list-reset ms-2 flex">
//         <li>
//           <a
//             href="#"
//             class="text-black/60 transition duration-200 hover:text-black/80 hover:ease-in-out focus:text-black/80 active:text-black/80 motion-reduce:transition-none dark:text-white/60 dark:hover:text-white/80 dark:focus:text-white/80 dark:active:text-white/80"
//             >Home</a
//           >
//         </li>
//         <li>
//           <span class="mx-2 text-black/60 dark:text-white/60">/</span>
//         </li>
//         <li>
//           <a
//             href="#"
//             class="text-black/60 transition duration-200 hover:text-black/80 hover:ease-in-out focus:text-black/80 active:text-black/80 motion-reduce:transition-none dark:text-white/60 dark:hover:text-white/80 dark:focus:text-white/80 dark:active:text-white/80"
//             >Library</a
//           >
//         </li>
//         <li>
//           <span class="mx-2 text-black/60 dark:text-white/60">/</span>
//         </li>
//         <li>
//           <a
//             href="#"
//             class="text-black/60 transition duration-200 hover:text-black/80 hover:ease-in-out focus:text-black/80 active:text-black/80 motion-reduce:transition-none dark:text-white/60 dark:hover:text-white/80 dark:focus:text-white/80 dark:active:text-white/80"
//             >Data</a
//           >
//         </li>
//       </ol>

//         <div className="ms-3">
//           <ul className="list-style-none me-auto flex flex-col ps-0 lg:mt-1 lg:flex-row">
//             <li className="my-4 ps-2 lg:my-0 lg:pe-1 lg:ps-2">
//               <Link href="/addcompany">Add Company</Link>
//             </li>
//           </ul>
//         </div>

//       </div>

      
//     </nav>
//   )
// }


// ============================
// components/Navigation.js

// import Link from 'next/link';
// import { useRouter } from 'next/router';
// import styles from './Navigation.module.css'; // Import CSS module

// const Navigation = () => {
//   const router = useRouter();

//   return (
//     <nav className={styles.nav}>
//       <Link href="/">
//         <a className={router.pathname === '/' ? styles.active : ''}>Home</a>
//       </Link>
//       <Link href="/about">
//         <a className={router.pathname === '/about' ? styles.active : ''}>About</a>
//       </Link>
//       {/* Add more navigation links as needed */}
//     </nav>
//   );
// };

// export default Navigation;
