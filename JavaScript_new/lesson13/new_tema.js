/*
* ЗАДАНИЯ
* */


//2) Создайте кнопку, по нажатию на которую будет всплывать окно с надписью: "Вы успешно нажали на кнопку"
//3) Создайте кнопку и параграф со случайным текстом, при нажатии на кнопку обрезать текст на половину и добавить в конце три точки
//4) Создайте пустое поле и кнопку, при нажатии на которую, будет проводиться проверка на пустоту поля
//5) Создайте массив объектов со следующими свойствами: productTitle (тип данных: строка), productSlug (тип данных: число),
//   productPrice (тип данных: число), productCount (тип данных: число);
//6) Создайте кнопку (фильтр по цене) и выведите созданный массив в консоль. Фильтрацию массива сделайте по цене (все товары больше 1500)
//7) Создайте кнопку (фильтр по количеству) и выведите созданный массив в консоль. Фильтрацию массива сделайте по количеству (все товары, количество которых больше 10)

// document.querySelector('.increase') - обращение к элементу
// const increaseBtn = document.querySelector('.increase') //в переменную increaseBtn поместили кнопку с классом "increase"
// console.log(document.querySelector('.increase')); //. - класс, # - id //обращение к элементам
// console.log(increaseBtn);
// console.log(document.querySelector('#id_1')); //обращение к элементам
// console.log(document.querySelector('p')); //обращение к элементам

// console.log(document.querySelector('.input-value').value);
// console.log(document.querySelector('.input-value').name);
// console.log(document.querySelector('p').textContent); //получить контент в теге
// console.log(document.querySelector('p').innerHTML); //получить контент html
// document.querySelector('.navbar-list').innerHTML = '' //удаление всего содержимого

// console.log(document.querySelector('.navbar-list__item'))
// console.log(document.querySelectorAll('.navbar-list__item'))
// document.querySelectorAll('.navbar-list__item').forEach(listItem => {
    // listItem.textContent =  listItem.textContent + '...'
    // console.log(listItem.classList.contains('navbar-list__item_hover')); //проверяет наличие класса у элемента
    // listItem.classList.add('navbar-list__item_hover') //добавление класса
    // console.log(listItem.classList);
    // listItem.classList.remove('navbar-list__item_hover') //удаляет класса
    // console.log(listItem.classList);
    // listItem.classList.toggle('navbar-list__item_hover')
    // console.log(listItem.classList);
// })

// document.querySelector('.navbar-list').querySelector('.navbar-list_item').classList.add('user-list_item-link_active')

/*
СОБЫТИЯ
*/
// const increaseBtn = document.querySelector('.increase');
// const inputCounter = document.querySelector('.input-value');
// const selectEleme = document.querySelector('.langSelect');

// increaseBtn.addEventListener('click', () => {
    // if(inputCounter.value.length === 2){
    // if(inputCounter.value === '10'){
    // if(Number(inputCounter.value) === 10){
    //     alert('Достигнут лимит счетчика')
    // }else{
    //     inputCounter.value++
    // }

    // document.querySelector('.user-list_item-link').classList.add('user-list_item-link_active');
// })
// document.querySelector('.increase').addEventListener('click', function(){
//     if(Number(inputCounter.value) === 10){
//         alert('Достигнут лимит счетчика')
//     }else{
//         inputCounter.value = Number(inputCounter.value) + 1
//     }

// })

// selectEleme.addEventListener('change', () => {
//     console.log(selectEleme.value);
// })

// console.log([...document.querySelector('.navbar-list').children].sort((a, b) => a.textContent > b.textContent ? 1 : -1))
// console.log(document.querySelector('.navbar-list').childNodes);