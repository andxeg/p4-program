ЗАДАНИЕ ВЫПОЛНИЛ ЧУПАХИН АНДРЕЙ, СТУДЕНТ 521 ГРУППЫ.

Были реализованы таблицы из Bridging and Routing: все от Ingress Port
до Policy ACL + L2 Interface.

Реализовать OF-DPA pipeline на P4 оказалось достаточно непростой задачей. P4 
очень жестко задает ограничения на матчинг в таблице. Также в actions в
P4 таблицах достаточно небольшой набор доступных функций. Ветвление есть
только в control блоках. При программироании выяснилось, что ветвление 
нужно делать очень аккуратно, так как компилятор P4 "ругается" почему-то
даже на правильные вещи. Примеры приведены ниже(См. КОММЕНТАРИИ).
    В итоге код не смог скомплироваться(См. КОММЕНТАРИИ).


Код можно найти по ссылке -> https://github.com/andxeg/p4-program/tree/master/ofdpa/p4src


Как запускать:
1)  Скачать p4factory -> https://github.com/p4lang/p4factory/
2)  Создать в нем новый проект, скопировать туда папку 
    ofdpa из репозитория https://github.com/andxeg/p4-program/tree/master/ofdpa
3)  Зайти в папку ofdpa и выполнить команду make bm




===================================КОММЕНТАРИИ=================================

Ошибку выдает компилятор Table 'policy_acl' is invoked multiple times.
Хотя они в разных путях выполнения и никогда реально два раза 
мы не попадем в эту таблицу. Это проблема компилятора. Он ищет
рекурсивно, следовательно 


-----------------------------------ОШИБКА!!!-----------------------------------

apply(ingress_port) {
    hit {
        process_vlan();
    }
    miss {
        // Policy ACL is a penultimate table;
        // L2 Interface is the last table 
        // and it is a group table.
        process_policy_acl();
    }
}


control process_vlan {
    apply(vlan) {
        hit {
            if (not valid(vlan_tag_[0])) {
                // If label was popped.
                process_vlan_1();
            } else {
                // If label was modified
                process_termination_mac();
            }
        }
        miss {
            process_policy_acl(); // Delete
        }
    }
}

control process_termination_mac {

}

control process_vlan_1 {
    apply(vlan_1);
}


control process_policy_acl {
    apply(policy_acl);
}



-----------------------------------ОШИБКА!!!-----------------------------------
apply(ingress_port) {
    normal_ethernet_set_vrf {
        process_policy_acl();
    }
    normal_ethernet_not_set_vrf {
        process_policy_acl();
    }
}


-----------------------------------ОШИБКА!!!-----------------------------------
if (2 > 1){
    apply(ingress_port) {
        hit {
            apply(ingress_port_mapping);
        }
        miss {
            apply(policy_acl);
        }
    }
} else {
    apply(ingress_port);
}




------------------------------------ОК!!!--------------------------------------
Но ошибка не возникает почему-то в следующих случаях:
1) 
    if (2 > 1) {
        process_policy_acl();
    } else {
        process_policy_acl();
    }    



2) 	if (2 > 1) {
        apply(table1);
    } else {
        apply(table1);
    }    


------------------------------------ПРИЧИНА------------------------------------

	Если ты используешь в двух путях выполнения конструкцию apply 
(типа switch, а не просто apply), то все падает.



ХОТЕЛОСЬ БЫ СДЕЛАТЬ ВОТ ТАК, НО ОШИБКИ КОМПИЛЯТОРА НЕ ПОЗВОЛЯЮТ.
control process_vlan {
    // Check vlan labels.
    // You must check existence of VLAN labels.
    // If vlan_tag_[1] is existed then vlan_tag_[0] is also existed.

    if (valid(vlan_tag_[0]) and valid(vlan_tag_[1])) {
        // process outer vlan label in double tagged packet
        apply(vlan) {
            hit {
                if (not valid(vlan_tag_[0])) {
                    // If label was popped.
                    process_vlan_1();
                } else {
                    // If label was modified
                    process_termination_mac();
                }
            }
            miss {
                process_policy_acl();
            }
        }
    } else if (valid(vlan_tag_[0]) and not valid(vlan_tag_[1])) {
        // process outer vlan label in single tagged packet
        apply(vlan) {
            hit {
                if (not valid(vlan_tag_[0])) {
                    // If label was popped.
                    process_termination_mac();
                } else {
                    // If label was modified
                    // process_vlan_1();
                }
            }
            miss {
                process_policy_acl(); // Delete
            }
        }
    }
}


ПОЭТОМУ БЫЛА ВВЕДЕНА СТРУКТУРА  intrinsic_metadata_t, в которой я запоминал
какое правило сработало, у какой таблицы. По этой информации я смог написать
обработку пакета, используя уже if-else вместо apply(table) { miss {} hit {} }

Но как оказалось, компилятор все равно "ругается". Видимо, это его баг или 
особенность работы.

Можно легко понять, что при выполнении программы два раза одна и таже таблица
не вызовется. Рассмотрим все возможные трассы выолнения программы. Если 
найдется такая трасса, в которой два раза повторяется таблица, то это
означает, что в pipeline есть цикл, что неверно. Получили противоречие.

Видимо, компилятор когда видит apply(table) объявляет какие-то глобальные
переменные. При повторном объявлении все и падает. 
