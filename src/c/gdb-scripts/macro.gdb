# define a custom gdb command
define dump_ll
   set $list = ($arg0)
   while ((struct linked_list*)$list->next != 0)
      p $list->id
      set $list = $list->next
   end
end
document dump_ll
   dump_ll <list>: Walk the linked list
end

