import React from 'react';
import s from './Navbar.module.css'
import {NavLink} from "react-router-dom";
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
            <div className={s.item}>
                <NavLink to='/profile' className = {navData => navData.isActive ? s.activeLink : s.item}>
                    Profile</NavLink>
            </div>
            <div className={s.item}>
                <NavLink to='/dialogs' className = {navData => navData.isActive ? s.activeLink : s.item}>
                    Messages</NavLink>
            </div>
            <div className={s.item}>
                <NavLink to='/news' className = {navData => navData.isActive ? s.activeLink : s.item}>
                    News</NavLink>
            </div>
            <div className={s.item}>
                <NavLink to='/music' className = {navData => navData.isActive ? s.activeLink : s.item}>
                    Music</NavLink>
            </div>
            <div className={s.item}>
                <NavLink to='/settings' className = {navData => navData.isActive ? s.activeLink : s.item}>
                    Settings</NavLink>
            </div>
        </nav>
    )
}

export default Navbar;