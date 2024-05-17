function getAjax(url, success) {
    var xhr = window.XMLHttpRequest ? new XMLHttpRequest() : new ActiveXObject('Microsoft.XMLHTTP');
    xhr.open('GET', url);
    xhr.onreadystatechange = function () {
        if (xhr.readyState > 3 && xhr.status == 200) success(xhr.responseText);
    };
    xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
    xhr.send();
    return xhr;
}

// getAjax('https://jsonplaceholder.typicode.com/posts', function(data){ console.log(data); });

//GET - нужен для получения данных
//POST - нужен для отправки данных
//PUT - изменение существующего
//DELETE - удаления 

fetch('https://jsonplaceholder.typicode.com/posts', { method: 'GET' })
    .then((res) => res.json())
    .then((result) => console.log(result))

const obj = {
    id: 101,
    name: 'Lorem',
    email: 'Lorem',
    phone: 3
}

fetch('https://jsonplaceholder.typicode.com/posts', {
    method: 'POST',
    body: obj
})
    .then((res) => res.json())
    .then((result) => console.log(result))

const userForm = document.querySelector('.fetch__form');
const regName = /^[a-zA-Z]+$/;
const regEmail = /^(?:[\w\!\#\$\%\&\'\\+\-\/\=\?\^\\{\|\}\~]+\.)[\w\!\#\$\%\&\'\*\+\-\/\=\?\^\\{\|\}\~]+@(?:(?:(?:[a-zA-Z0-9](?:[a-zA-Z0-9\-](?!\.)){0,61}[a-zA-Z0-9]?\.)+[a-zA-Z0-9](?:[a-zA-Z0-9\-](?!$)){0,61}[a-zA-Z0-9]?)|(?:\[(?:(?:[01]?\d{1,2}|2[0-4]\d|25[0-5])\.){3}(?:[01]?\d{1,2}|2[0-4]\d|25[0-5])\]))$/;



const nameValidation = (userName) => {
    if (regName.test(userName)) { return true; }
    else { alert('Invalid user name') }
}
const emailValidation = (userEmail) => {
    if (regEmail.test(userEmail)) { return true; }
    else { alert('Invalid user email') }
}
IMask(
    userForm.querySelector('input[name="user-phone"]'),
    {
        mask: '+{7}(000)000-00-00'
    }
)

userForm.querySelector('input[name="user-name"]')
    .addEventListener('change', (e) => { nameValidation(e.target.value) })

userForm.querySelector('input[name="user-email"]')
    .addEventListener('change', (e) => { emailValidation(e.target.value) })



userForm.addEventListener('submit', (e) => {
    e.preventDefault();
    const formData = new FormData(userForm);
    if (formData.get('user-name').length < 2 || formData.get('user-email').length < 2 || formData.get('user-phone').length < 2) {
        alert('Some inputs are empty')
    } else {
        fetch('http://make-run-now.ru/v35/create-user', {
            method: 'POST',
            body: JSON.stringify({
                name: formData.get('user-name'),
                email: formData.get('user-email'),
                phone: formData.get('user-phone'),
            })
        })
            .then(res => res.json())
            .then(data => console.log(data))
    }
})

//Ответ от сервера закинуть в localStorage
//Отрисовка объекта из localStorage

// localStorage.setItem('user', JSON.stringify({name: 'Anna', age: 25}));

// console.log(JSON.parse(localStorage.getItem('user')));

// localStorage.removeItem('user');

// document.querySelector('.form').addEventListener('submit', (e)=>{
//     e.preventDefault();

//     console.log(document.querySelector('.form').querySelectorAll('.form__input'));

//     const formData = new FormData(document.querySelector('.form'));
//     console.log([...formData]);
// })