Задание можно посмотреть по ссылке -> http://www.alexander-shalimov.com/advsdn17

Комментарии от Саши Шалимова:
1) 	Достаточно от первой (Ingress Port) до ACL и возможность отправки на порт - групповые записи. Т.е. группы L2 Interface
2) 	Александр Шалимов: "в общем критерий такой, чтобы пакеты через pipeline проходили. 
	В решении должна быть хотя бы одна таблица, которая делает group output"


	Нам нужно реализовать все от ingress port до Policy ACL Flow Table.
	Из групповой таблицы нужно реализовать только одну таблицу L2 Interface(Indirect)
	И после этого сразу пакет на egress port.

	Как работает групповая таблица. Пришел пакет на коммутатор, над ним выполнились некоторые действия,
	далее вместо OUTPUT_ACTION может быть ACTION посылки в групповую таблицу с некоторым ID.

	В задании рассматривается только indirect групповая таблица. Она состоит только из одного bucket, в этом
	bucket только одно правило.


3)	Валя порекомендовала опираться на этот документ при выполнении задания.
	Если что-то не понятно, то смотреть в спецификацию.
	https://github.com/Broadcom-Switch/of-dpa.
	Json TTP(Type Table Pattern). Json с описанием OFDPA pipeline 




_______________________________________________________________________________
P4
1.	http://p4.org/spec/
2.	http://p4.org/p4-faq/



p4factory -> https://github.com/p4lang/p4factory

Смотреть  нужно tutorials, а не p4factory. Это сказал разраб 18 дней назад -> https://github.com/p4lang/p4factory/issues/190
Чтобы все настроить перед запуском прог из tutorials См. -> https://github.com/p4lang/tutorials/tree/master/SIGCOMM_2015#obtaining-required-software


Чтобы версия v1_1 работа, нужно доустановить пакеты для компилятора 'p4c-bm'. Смотри ссылку ->  https://github.com/p4lang/p4c-bm


Со стандартным мининетом в ubuntu 14.04 не работает. Установил мининет так -> https://sdn-lab.com/2014/12/31/setting-up-mininet-2-2-on-ubuntu-12-04-and-14-04/



SEE -> https://www.youtube.com/watch?v=KQ3nSqV9iw8


VERY USEFUL. WITH ALL FIELDS. 	https://github.com/p4lang/switch/tree/master/p4src
								https://github.com/p4lang/papers/tree/master/sosr15/DC.p4


Все ссылки на репозитории в github.
1.	OF-PDA. https://github.com/Broadcom-Switch/of-dpa/
2.	P4 tutorial. https://github.com/p4lang/tutorials/tree/master/p4v1_1/simple_router
3.	How configure envirinment for P4 pgroram compiling. https://github.com/p4lang/tutorials/tree/master/SIGCOMM_2015
4.	Behavioral model. P4 program switch. https://github.com/p4lang/behavioral-model
5.	p4factory. Examples with p4 program and mininet integration. https://github.com/p4lang/p4factory
6.	Switch on P4. Very usefull, this repo contains header and packet parsing. https://github.com/p4lang/switch/tree/master/p4src
7.	Repo with headers. https://github.com/p4lang/papers/tree/master/sosr15/DC.p4
