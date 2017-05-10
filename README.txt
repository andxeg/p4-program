Комментарии к решению.


Ошибку выдает компилятор Table 'policy_acl' is invoked multiple times.
Хотя они в разных путях выполнения и никогда реально два раза 
мы не попадем в эту таблицу. Это проблема компилятора. Он ищет
рекурсивно, следовательно 


===================================ОШИБКА!!!===================================

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



===================================ОШИБКА!!!===================================
apply(ingress_port) {
    normal_ethernet_set_vrf {
        process_policy_acl();
    }
    normal_ethernet_not_set_vrf {
        process_policy_acl();
    }
}


===================================ОШИБКА!!!===================================
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




===================================ОК!!!=======================================
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



===================================ПРИЧИНА=====================================
	Если ты используешь в двух путях выполнения конструкцию apply 
(типа switch, а не просто apply), то все падает.




