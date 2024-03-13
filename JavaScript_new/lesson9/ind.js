/*
* COOKIE
* */
//Запись в куки
document.cookie = 'user=Jhon';
console.log(document.cookie);
//Задать время жизни
document.cookie = 'user=Jhon; max-age=3600';
//Получить cookie по имени
function getCookie(name){
    const value = `; ${document.cookie}`;
    const parts = value.split(`; ${name}=`);
    if(parts.length === 2) return parts.pop().split(';').shift();
}
console.log(getCookie());
//Удаление cookie
document.cookie = 'user=Jhon; max-age=-1';



/*
 *LocalStorage (принимает и работает строго со строками)
 * */
//Запись в localStorage
localStorage.setItem('userName', 'Anna');
const person = [
    {
        id: 1,
        userName: 'Alex',
        age: 29,
        sallery: 25000
    },
    {
        id: 2,
        userName: 'Max',
        age: 39,
        sallery: 45000
    },
    {
        id: 3,
        userName: 'Oleg',
        age: 25,
        sallery: 35000
    }
]
localStorage.setItem('person', JSON.stringify(person));
//Получение из localStorage
console.log(localStorage.getItem('userName'));
console.log(JSON.parse(localStorage.getItem('person')));
//Удаление из localStorage
localStorage.removeItem('userName')


/*
* sessionStorage
* */
//Запись в sessionStorage
// sessionStorage.setItem('userName', 'Anna')
//Получение из sessionStorage
// console.log(sessionStorage.getItem('userName'))
//Удаление из sessionStorage
// sessionStorage.removeItem('userName');
//Удалить все из sessionStorage
// sessionStorage.clear();
