/*
* �������
* */


//2) �������� ������, �� ������� �� ������� ����� ��������� ���� � ��������: "�� ������� ������ �� ������"
//3) �������� ������ � �������� �� ��������� �������, ��� ������� �� ������ �������� ����� �� �������� � �������� � ����� ��� �����
//4) �������� ������ ���� � ������, ��� ������� �� �������, ����� ����������� �������� �� ������� ����
//5) �������� ������ �������� �� ���������� ����������: productTitle (��� ������: ������), productSlug (��� ������: �����),
//   productPrice (��� ������: �����), productCount (��� ������: �����);
//6) �������� ������ (������ �� ����) � �������� ��������� ������ � �������. ���������� ������� �������� �� ���� (��� ������ ������ 1500)
//7) �������� ������ (������ �� ����������) � �������� ��������� ������ � �������. ���������� ������� �������� �� ���������� (��� ������, ���������� ������� ������ 10)

// document.querySelector('.increase') - ��������� � ��������
// const increaseBtn = document.querySelector('.increase') //� ���������� increaseBtn ��������� ������ � ������� "increase"
// console.log(document.querySelector('.increase')); //. - �����, # - id //��������� � ���������
// console.log(increaseBtn);
// console.log(document.querySelector('#id_1')); //��������� � ���������
// console.log(document.querySelector('p')); //��������� � ���������

// console.log(document.querySelector('.input-value').value);
// console.log(document.querySelector('.input-value').name);
// console.log(document.querySelector('p').textContent); //�������� ������� � ����
// console.log(document.querySelector('p').innerHTML); //�������� ������� html
// document.querySelector('.navbar-list').innerHTML = '' //�������� ����� �����������

// console.log(document.querySelector('.navbar-list__item'))
// console.log(document.querySelectorAll('.navbar-list__item'))
// document.querySelectorAll('.navbar-list__item').forEach(listItem => {
    // listItem.textContent =  listItem.textContent + '...'
    // console.log(listItem.classList.contains('navbar-list__item_hover')); //��������� ������� ������ � ��������
    // listItem.classList.add('navbar-list__item_hover') //���������� ������
    // console.log(listItem.classList);
    // listItem.classList.remove('navbar-list__item_hover') //������� ������
    // console.log(listItem.classList);
    // listItem.classList.toggle('navbar-list__item_hover')
    // console.log(listItem.classList);
// })

// document.querySelector('.navbar-list').querySelector('.navbar-list_item').classList.add('user-list_item-link_active')

/*
�������
*/
// const increaseBtn = document.querySelector('.increase');
// const inputCounter = document.querySelector('.input-value');
// const selectEleme = document.querySelector('.langSelect');

// increaseBtn.addEventListener('click', () => {
    // if(inputCounter.value.length === 2){
    // if(inputCounter.value === '10'){
    // if(Number(inputCounter.value) === 10){
    //     alert('��������� ����� ��������')
    // }else{
    //     inputCounter.value++
    // }

    // document.querySelector('.user-list_item-link').classList.add('user-list_item-link_active');
// })
// document.querySelector('.increase').addEventListener('click', function(){
//     if(Number(inputCounter.value) === 10){
//         alert('��������� ����� ��������')
//     }else{
//         inputCounter.value = Number(inputCounter.value) + 1
//     }

// })

// selectEleme.addEventListener('change', () => {
//     console.log(selectEleme.value);
// })

// console.log([...document.querySelector('.navbar-list').children].sort((a, b) => a.textContent > b.textContent ? 1 : -1))
// console.log(document.querySelector('.navbar-list').childNodes);