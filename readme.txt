#######################################
## Mouadh ABOUD           #############
##		              	    #############
#######################################


Scripts order : 
1 - ansible-playbook -i inventory.ini Playbook.yml
2 - ansible-playbook -i inventory.ini ubuntu_exec.yml
3 - ansible-playbook -i inventory.ini lynis_ubuntu_exec.yml
4 - ansible-playbook -i inventory.ini reverse_copy_ubuntu_exec.yml
5 - ansible-playbook -i inventory.ini redhat_exec.yml
6 - ansible-playbook -i inventory.ini lynis_redhat_exec.yml
7 - ansible-playbook -i inventory.ini reverse_copy_redhat_exec.yml
