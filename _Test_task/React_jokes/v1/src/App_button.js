import React from 'react'
import cssData from './App_button.module.css'
import handleClick from './App_event'
const App_button = () => {
    return (
        <button className={cssData.joke_btn} onClick={handleClick}>Get any joke</button>
    )
}
export default App_button