import React from 'react';
import s from './MyPosts.module.css'
import Post from './Post/Post'

const MyPosts = () => {
    return (
        <div>
            My posts
            <div>
                <textarea></textarea>
                <button>Send post</button>
            </div>
            <div className={s.posts}>
                <Post message='Hi, how are you?' likes='15'/>
                <Post message="It's my first post." likes='30' />
            </div>
        </div>
    )
}

export default MyPosts;