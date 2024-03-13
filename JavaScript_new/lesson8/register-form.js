const registerForm = document.querySelector('.form__register');
const loginInput = document.querySelector('.register-login-input');
const loginError = document.querySelector('.register-login-input-error');
const passwordInput = document.querySelector('.register-password-input');
const passwordError = document.querySelector('.register-password-input-error');
const repeatPasswordInput = document.querySelector('.repeat-register-password-input');
const repeatPasswordError = document.querySelector('.repeat-register-password-input-error');

function simpleValidateItem(itemInput, itemError, errorText){
    if(
        itemInput.value &&
        itemInput.value !== '' &&
        itemInput.value !== ' ' &&
        itemInput.value !== null &&
        itemInput.value.length <= 8 
    ) { console.log('All okey')  }
    else{ itemError.textContent = errorText }
}

loginInput.onfocus = function (){
    loginError.textContent = ' '
}
passwordInput.onfocus = function (){
    passwordError.textContent = ' '
}
repeatPasswordInput.onfocus = function (){
    repeatPasswordError.textContent = ' '
}

registerForm.addEventListener('submit', (e) => {
    e.preventDefault();

    simpleValidateItem(loginInput, loginError, 'Введите логин')
    simpleValidateItem(passwordInput, passwordError, 'Введите Пароль')
    simpleValidateItem(repeatPasswordInput, repeatPasswordError, 'Введите Повторный Пароль')

    if(passwordInput.value !== repeatPasswordInput.value){
        passwordError.textContent = 'Пароли не совпадают'
        passwordError.textContent = 'Пароли не совпадают'
    }

})