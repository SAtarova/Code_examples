import React from 'react';
import './App.css';
//import Tehnologies from './Tehnologies';
import Header from './components/Header';
import Navbar from './components/Navbar';
import Profile from './components/Profile';
//import Footer from './Footer';

const App = () => {
  return (
    <div className='app-wrapper'>
      <Header />
      <Navbar />
      <Profile />
    </div>
  );
}

export default App;
