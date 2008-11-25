#!/usr/bin/env python
#
#   hostmap
#
#   Author:
#    Alessandro `jekil` Tanasi <alessandro@tanasi.it>
#
#   License:
#    This program is private software; you can't redistribute it and/or modify
#    it. All copies, included printed copies, are unauthorized.
#    
#    If you need a copy of this software you must ask for it writing an
#    email to Alessandro `jekil` Tanasi <alessandro@tanasi.it>



from lib.core.outputDeflector import *



class jobs:
    """ 
    Job manager and controller
    @author:       Alessandro Tanasi
    @license:      Private software
    @contact:      alessandro@tanasi.it
    """
    
    
    
    def __init__(self, debug = False):
        """
        Initialize job controller
        @params debug: enable debug mode
        """
        # It stores the status of each job, that can be:
        # - Starting
        # - Waiting
        # - Done
        # - Failed
        # Syntax is: 
        # {jobname: status}
        self.jobs = {}
        
        # Tag used in all output messages
        self.tag = "JOB"
        
        # Job controller debug mode
        self.debug = debug



    def alter(self, job, status):
        """
        Store the change of status of jobs. Each job call this function when change its status.    
        @params job: job's name
        @params status: current status of the job
        """
        
        self.jobs[job] = status
        log.debug("Job %s changed status to %s" % (job, status), time=True, tag=self.tag)
        
        # If i debug mode print job status at every call
        if self.debug:
            log.debug("DEBUG MODE: printing job tree at every job change", time=True, tag=self.tag)
            #self.status()
            
        # Check if all jobs are doneself.engine.alter
        #self.__jobIsDone()



    def check(self):
        """
        Check if all jobs are done
        @returns: boolean that say if all jobs are done
        """
        
        # The work is done when all jobs are in done or failure state
        for key, value in self.jobs.items():
            if value == "done" or value == "failure":
                done = True
            else:
                done = False
                return False

        # Work done
        if done:
            # All jobs are now done
            log.debug("All jobs done", time=True, tag=self.tag)
            return True



    def status(self):
        """
        Print the status of the jobs, used only for debug
        """
        
        log.debug("Current job status:", time=True, tag=self.tag)
        
        # Print the status of each job
        for job, status in self.jobs.items():
            log.debug("> %s : %s" % (job, status),  time=True,  tag=self.tag)
