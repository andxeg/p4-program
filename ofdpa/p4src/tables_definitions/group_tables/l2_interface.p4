
action l2_interface_action() {
    
}


table l2_interface {
    actions {
        l2_interface_action;       
    }
    size : L2_INTERFACE_GROUP_TABLE_SIZE;
}


control process_l2_interface {
    
}