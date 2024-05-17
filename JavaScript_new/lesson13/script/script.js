document.querySelector('.comment-form-2').addEventListener('submit', (e)=> {
    console.log(e);
    e.preventDefault();
    
    console.log([...document.querySelector('.comment-form-2').querySelectorAll('input')]);
    [...document.querySelector('.comment-form-2').querySelectorAll('input')]
    .forEach(item => {
        console.log(item.name)  
        console.log(item.value)  
    })
    
    
    const inputs = new FormData(document.querySelector('.comment-form-2'))
    for (const [key, value] of inputs) {
        console.log(`${key}: ${value}`);
    }

})

// 1. Создать форму авторизации (логин, пароль, флаг "запомнить").
//    Если пользователь выбрал флаг "запомнить", то при перезагрузке страницы
//    форма больше не появляется, но появляется кнопка "LogOut" для удаления данных
// 2. Создать несколько товаров (заголовок, кнопка добавить), при нажатии на кнопку
//    добавить, происходит добавление товара в localStorage и увеличивается счетчик 
//    кол-ва выбранного товара на странице
// 3. Создать форму с именем пользователя, при нажатии на кнопку отправить, происходит
//    добавление пользователя в localStorage и после перезагрузки страницы будет вспылвать
//    приветственное сообщение с именем пользователя.

/*EXAMPLE*/
let user = {
    id: 1, 
    name: 'Anna',
    age: 25
}

/*Add item to localstorage */
localStorage.setItem('item', JSON.stringify(user))
/*Get item to localstorage */
JSON.parse(localStorage.getItem('item'))
/*Remove item from localstorage */
localStorage.removeItem('item');
