import React from 'react'
import s from './Profile.module.css'
import MyPosts from './MyPosts/MyPosts'

const Profile = () => {
    return (
        <div className={s.content}>
            <div>
                <img className={s.content_main_img} src='./image_content.jpg' alt='content_img' />
            </div>
            <div>
                <img className={s.butterfly} src='./gamemntze-butterfly.png' alt='profile_img' />
                Description
            </div>
            <MyPosts />            
        </div>
    )
}

export default Profile