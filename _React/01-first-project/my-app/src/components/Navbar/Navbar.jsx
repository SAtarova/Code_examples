import React from 'react';
import s from './Navbar.module.css'
console.log(s)

// let classes = {
//     'nav': 'Navbar_nav_0034F',
//     'item': 'Navbar_item_0034F',
//     'active': 'Navbar_active_0034F'
// }

const c1 = 'item'
const c2 = 'active'
// 'item active'
const cString = c1 + ' ' + c2
let stringNew = `${s.item} ${s.active}`

const Navbar = () => {
    return (
        <nav className={s.nav}>
            <div className={stringNew}>
                <a>Profile</a>
            </div>
            <div className={stringNew}>
                <a>Messages</a>
            </div>
            <div className={stringNew}>
                <a>News</a>
            </div>
            <div className={stringNew}>
                <a>Music</a>
            </div>
            <div className={stringNew}>
                <a>\n</a>
            </div>
            <div className={stringNew}>
                <a>Settings</a>
            </div>
        </nav>
    )
}

export default Navbar;