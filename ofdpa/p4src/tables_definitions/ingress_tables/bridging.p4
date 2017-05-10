

action bridging_action() {

}


table bridging {
    actions {
        bridging_action;
    }
}

control process_bridging {
    apply(bridging);
}
