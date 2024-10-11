#######################################
## Mouadh ABOUD           #############
##		              	    #############
#######################################

# Before you start you need to : #
- Install ansible on ansible_VM 
- then you need to create a /data FS with 5GB on each VM
- you need to update inventory.ini file
- confingure passwordless connextion between each target VM and ansible_VM
![Dessin](https://github.com/user-attachments/assets/79eecc03-e124-4b58-a710-ff0a90971ba9)


before executing run this ommand in your folder 
> dos2unix *.sh
 
 - ansible-playbook -i inventory.ini Playbook.yml
 - ansible-playbook -i inventory.ini ubuntu_exec.yml
 - ansible-playbook -i inventory.ini lynis_ubuntu_exec.yml
 - ansible-playbook -i inventory.ini reverse_copy_ubuntu_exec.yml
 - ansible-playbook -i inventory.ini redhat_exec.yml
 - ansible-playbook -i inventory.ini lynis_redhat_exec.yml
 - ansible-playbook -i inventory.ini reverse_copy_redhat_exec.yml

![image](https://github.com/user-attachments/assets/37c286ba-9ae9-4286-9d0d-aee27f457ece)

![image](https://github.com/user-attachments/assets/0d1789a2-7544-4318-8c50-71c7cd7423b1)

![image](https://github.com/user-attachments/assets/bc8df564-9ce5-4fe0-b35e-de51773ba002)



