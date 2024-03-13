const registerForm  = document.querySelector('.form-register');
const registerLogin = document.querySelector('.login-form');
const registerTitle = document.querySelector('.log-out');
const countProducts = document.querySelector('.count');

window.addEventListener('DOMContentLoaded', () => {
    if(localStorage.getItem('userData')){
        let userInfo = JSON.parse(localStorage.getItem('userData'))
        if(userInfo.userSignIn){
            document.querySelector('.title').textContent = `Hello ${userInfo.userName}`
        }
        else{
            document.querySelector('.title').textContent = `Please SignIn`
        }
    }
})

registerForm.addEventListener('submit', (e) => {
    e.preventDefault();
    
    const formDataInfo = new FormData(registerForm)
    if(formDataInfo.get('user-password') !== formDataInfo.get('user-password-next')){
        alert('Wrong passwords!');
        registerForm.reset;
    }
    
    localStorage.setItem('userData', JSON.stringify({
        userName:   formDataInfo.get('user-name'), 
        userPass:   formDataInfo.get('user-password'),
        userSignIn: false
    }
    
    ))
    registerForm.reset();
})

registerLogin.addEventListener('submit', (e) => {
    e.preventDefault();

    const formDataLogin = new FormData(registerLogin)
    let locLocalStorage = JSON.parse(localStorage.getItem('userData'))

    if ((formDataLogin.get('login-name') !== locLocalStorage.userName) || (formDataLogin.get('login-password') !== locLocalStorage.userPass))
    {
        alert('Wrong password!');
        formDataLogin.reset;
    }
    else
    {
        alert(`Hello mr. ${formDataInfo.get('login-name')}`)
        //Прописываем новый тайтл с именем
        document.querySelector('.title').textContent = `Hello mr. ${formDataInfo.get('login-name')}`;
        locLocalStorage.userSignIn = true
    }
})

registerTitle.addEventListener('click', (e) => {
    localStorage.removeItem('userData')

})

document.querySelectorAll('.good-add').forEach(goodBtn => {

    goodBtn.addEventListener('click', (e) => {
        let productCount = e.target.parentElement.children[3];
        productCount.textContent = Number(productCount.textContent) + 1;

        let carttCount = document.querySelector('.count');
        carttCount.textContent = Number(carttCount.textContent) + 1;
    })
})
