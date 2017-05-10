
======================================ЗАДАНИЕ==================================
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




========================================ССЫЛКИ=================================
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


DSPC - Differentiated Service Code Point. Это поле в IP-заголовке. Размер: 6 бит.
OAM  - operation, administration and management
PDU  - protocol data unit
PCP  - Priority Code Point. Field in VLAN label. Identify class of service.


===================================ЗАГОЛОВКИ===================================

1. 	LLC header - logical link control.

2. 	SNAP - Subnetwork Access Protосоl.

3. 	RoCE and RoCE_v2 headers - RDMA over Converged Ethernet (RoCE) is a network 
	protocol that leverages Remote Direct Memory Access (RDMA) capabilities to 
	dramatically accelerate communications between applications hosted on clusters 
	of servers and storage arrays.

4. 	FCOE header - Fibre Channel over Ethernet

5.	IEEE 802.1ah-2008. PBB - Provider Backbone Bridges (PBB; known as "mac-in-mac")
	is a set of architecture and protocols for routing over a provider's network 
	allowing interconnection of multiple Provider Bridge Networks without losing
	each customer's individually defined VLANs.

6.	SCTP - Streaming Control Transmission Protocol.

7.	GRE. Generic Routing Encapsulation (GRE) is a tunneling protocol developed 
	by Cisco Systems that can encapsulate a wide variety of network layer 
	protocols inside virtual point-to-point links over an Internet Protocol network.

8.	Network Virtualization using Generic Routing Encapsulation (NVGRE) 
	is a network virtualization technology that attempts to alleviate 
	the scalability problems associated with large cloud computing deployments.
	It uses Generic Routing Encapsulation (GRE) to tunnel layer 2 packets 
	over layer 3 networks. NVGRE is described in the IETF RFC 7637. 
	Its principal backer is Microsoft.

9.	EoMPLS - Ethernet over MPLS.

10.	Trill - TRILL ("Transparent Interconnection of Lots of Links")

11.	Lisp header. The Locator/ID Separation Protocol

12.	VN tag. Virtual NIC tag in Cisco.

13.	Bidirectional Forwarding Detection (BFD)

14.	


======================================MININET==================================
1.	Если возникнут ошибки при работе с mininet, то выполнить следующие команды:
	a.	sudo mn -c
	b.	sudo killall behavioral-model
	c.	redis-cli FLUSHALL


====================================РЕАЛИЗАЦИЯ=================================

1. 	tunnel_id - Со слов Вали. Некий аналог метадаты, который сопоставляется
	некоторому набору входных/выходных портов.

2.	LMEP_ID - ????

Ingress packets always have an associated Tunnel Id metadata value and may have an associated
LMEP_Id. Packets that enter the data plane from physical ports always have a zero Tunnel. Packets from
tunnel logical ports require a positive, non-zero Tunnel Id value to be assigned in order to identify the
tenant forwarding domain. The Tunnel Id logically accompanies the packet through the pipeline so that
when tenant packets are output, the Tunnel Id is supplied to the egress logical port.

3.	Double tagging -> https://en.wikipedia.org/wiki/IEEE_802.1Q#Double_tagging

4.	Tunnel_id можно проставлять на этапе парсинга в ingress_metadata. Потом в таблицах
	можно будет матчить по полю ingress_metadata.tunnel_id. Аналогично для LMEP_ID.
	На этапе парсинга можно использовать standard_metadata.

	Но можно сделать дополнительную таблицу в самом начале: port_mapping, и в ней
	уже ставить соответствие между портои и tunnel_id.

5.	Аналогии.
	table 	<---> class в ООП
	reads 	<---> параметры конструктора при создании экземпляра класса
	actions <---> методы класса

	В таблице P4-коммутатора будут стоять правила вида: "add_entry <table_name> <table_reads_params> <action_name> <action_params>"


6.	При написании опираюсь на https://github.com/p4lang/papers/blob/master/sosr15/DC.p4/includes/parser.p4

7.	ВАЖНО!!! https://github.com/p4lang/behavioral-model/blob/master/docs/JSON_format.md
	В самом низу есть объяснение ternary.

8.	OpenFlow actions types:
	a.	GOTO. Goto to the table.
	b.	APPLY - применить все накопившиеся правила. Обычно в стеке правил есть много
		SET_FIELD(правила, которые меняют значения пакета). Правил с переходами
		(OutputAction and Goto GROUP Table) не больше одного.
		i.	SET_FIELD - изменить поле
	c.	CLEAR.
	d.	WRITE Action - записать правило. Обычно записывают OutputAction на порт
		или Goto GROUP Table.



Вопросы:
1) 	Кто поставит VID метку. В описании json VID уже есть на нетегированном  трафике. Никто, будет miss.
2) 	Зачем таблицы VLAN 1? - pipeline криво написан
3) 	Проверять на valid нужно не в таблице, а до входа в нее. Это касается таблицы VLAN.
4)	Чем отличаются следующие записи:
	{
	  "field": "VLAN_VID ",
	  "value": "<vid>|0x1000",
	  "match_type": "exact"
	}

    {
      "field": "VLAN_VID ",
      "value": "0x1000",
      "match_type": "mask",
      "mask": "0x1000"
    }



    0x1000 - это выцепление VLAN метки. Если посмотреть на VLAN заголовок, то становится
    понятно: Сначала идет 4 бит, потом VID, отсюда 0x1000.
    header_type vlan_tag_t {
    fields {
        pcp : 3;
        cfi : 1;
        vid : 12;
        etherType : 16;
    }
}


5)	Как делать clear actions - никак
6)	Таблица VLAN. VLAN Assignment - Untagged. VLAN ID == 0. Если метки вообще нет? Если нет, то будет miss.


