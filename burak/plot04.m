clf
subplot(2,2,1)
plot(linspace(0,55,5500),2*mean(mapinresponse),'LineWidth',2)
hold on
boxplot((mapinresponse(:,1:100:end)))
set(gca,'FontSize',15)
xlabel('seconds')
 ylabel('std')


hold on
plot(linspace(0,55,5500),mean(gminresponse),'LineWidth',2)
boxplot((gminresponse(:,1:100:end)))



ylim([-2 2])
subplot(2,2,2)
plot(linspace(0,55,5500),2*mean(mapoutresponse),'LineWidth',2)
hold on
boxplot((mapoutresponse(:,1:100:end)))

plot(linspace(0,55,5500),mean(gmoutresponse),'LineWidth',2)
boxplot((gmoutresponse(:,1:100:end)))

ylim([-2 2])
xlabel('seconds')
 ylabel('std')


set(gca,'FontSize',15)


subplot(2,2,3)
[r,lags]=xcorr(mean(gminresponse),mean(mapinresponse));
plot(linspace((min(lags)/100),(max(lags)/100),length(lags)),r/1000,'LineWidth',2)
 xlim([-10 10])
 ylabel('r ')
xlabel('seconds')
set(gca,'FontSize',15)

subplot(2,2,4)
[r,lags]=xcorr(mean(gmoutresponse),mean(mapoutresponse));
plot(linspace((min(lags)/100),(max(lags)/100),length(lags)),r/1000,'LineWidth',2)
 xlim([-10 10])
 ylabel('r ')
xlabel('seconds')
 
set(gca,'FontSize',15)