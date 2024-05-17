// const arr = [
//     {
//         id: 1,
//         title: 'some text',
//     },
//     {
//         id: 1,
//         title: 'some text',
//     },
//     {
//         id: 2,
//         title: 'some text',
//     }
// ]
// let newArr = arr.reduce((acc, item) => {
//     if(!acc.some(elem => elem.id === item.id)){
//         acc.push(item)
//     }
//     return acc;
// }, [])
// console.log(newArr);

/*
Обращение к элементу
*/

// const inputNewID = document.getElementById('input1')
// console.log(inputNewID);
// const inputNewClassName = document.getElementsByClassName('input-field')
// console.log(inputNewClassName);
// const inputTagName = document.getElementsByTagName('input')
// console.log(inputTagName);
// const inputName = document.getElementsByName('name')
// console.log(inputName);

// const inputIDNEW = document.querySelector('#input1')
// const inputClassNameNEW = document.querySelector('.input-field')
// const inputTagNameNEW = document.querySelector('input')
// const inputNameAttr = document.querySelector('input[name ="name"]')
// console.log(inputIDNEW);
// console.log(inputClassNameNEW);
// console.log(inputTagNameNEW);
// console.log(inputNameAttr);

// const inputClassNameNEWAll = [...document.querySelectorAll('.input-field')]
// const inputTagNameNEWAll = document.querySelectorAll('input')
// console.log(inputClassNameNEWAll);
// console.log(inputTagNameNEWAll);


// const linkSingle = document.querySelectorAll('.simple-list__link');
// linkSingle.forEach((item, index) => {
//     item.textContent = (index + 1) + ' ' + item.textContent;
//     console.log(item.textContent);
// })
// const liSingle = document.querySelector('.simple-list__item');
// console.log(linkSingle.textContent);
// console.log(linkSingle.innerHTML);

// console.log(liSingle.textContent);
// console.log(liSingle.innerHTML);

// const inputsList = document.querySelectorAll('.input-field')
// inputsList.forEach(item => {
//     console.log(item.name);
//     item.value = ${item.name} hello
// })

// const textSimple = document.querySelectorAll('.simple-text')
// textSimple.forEach((item, index) => {
//     if(index % 2 === 0){
//         item.classList.add('text-agl')
//     }

    // item.classList.remove('simple-text')

    // item.classList.toggle('text-agl')

    // if(!item.classList.contains('text-agl')){
    //     item.classList.add('text-agl')
    // }else{
    //     item.classList.remove('text-agl')
    // }

// })


// const newDiv = document.createElement('p')
// newDiv.textContent = 'some text'
// newDiv.classList.add('new-elem')

// const parentDiv = document.querySelector('.actions')
// parentDiv.appendChild(newDiv)


// const newButton = <button class="simple-action">Call Back</button>;
// parentDiv.insertAdjacentHTML('beforebegin', newButton);
// parentDiv.insertAdjacentHTML('beforeend', newButton);
// parentDiv.insertAdjacentHTML('afterbegin', newButton);
// parentDiv.insertAdjacentHTML('afterend', newButton);


// const btns = document.querySelectorAll('.simple-action')
// btns.forEach((btnSingle, index) => {
//     btnSingle.addEventListener('click', () => {
//         document.querySelectorAll('.simple-text')[index].classList.toggle('text-agl')
//         console.log('some text');
//     })
// })


// document.querySelector('.simple-one').remove()