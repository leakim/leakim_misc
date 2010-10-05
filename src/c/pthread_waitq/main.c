
pthread_mutex_t queue_lock;
pthread_cond_t  not_empty;
queue_t queue;

push()
{
  pthread_mutex_lock(&queue_lock);
  queue.insert(new_job);
  pthread_cond_signal(&not_empty)
  pthread_mutex_unlock(&queue_lock);
}

pop()
{
  pthread_mutex_lock(&queue_lock);
  if(queue.empty()) 
     pthread_cond_wait(&queue_lock,&not_empty);
  job=quque.pop();
  pthread_mutex_unlock(&queue_lock);
}

