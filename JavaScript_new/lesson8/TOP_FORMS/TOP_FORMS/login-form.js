const loginError = document.querySelector('.login-input-login-error')
const passwordError = document.querySelector('.login-password-input-error')
const passwordInput = document.querySelector('.login-password-input')
const loginForm = document.querySelector('.form__sign-in');
const loginInput = document.querySelector('.login-input-login')

loginInput.addEventListener('input', function (e){
    loginInput.value = loginInput.value.replace(/[0-9]/g, '')
})

loginInput.onfocus = function (){
    loginError.textContent = ' '
}
passwordInput.onfocus = function (){
    passwordError.textContent = ' '
}


loginForm.addEventListener('submit', (e) => {
    e.preventDefault()

    if(
        loginInput.value &&
        loginInput.value !== '' &&
        loginInput.value !== ' ' &&
        loginInput.value !== null &&
        loginInput.value.length <= 8
    ) { console.log('All okey')  }
    else if(!' ' in loginInput.value){
        console.log('All okey') 
    }
    else{ loginError.textContent = 'Введите логин' }

    if(
        passwordInput.value &&
        passwordInput.value !== '' &&
        passwordInput.value !== ' ' &&
        passwordInput.value !== null &&
        passwordInput.value.length <= 15
    ){ console.log('All okey') }
    else{ passwordError.textContent = 'Введите Пароль' }
})