function [target_to_kick] = ball_kick (ball, position, goal)
    %agent is a ball     position is robo pos
%     disp('in func b_k');
    
    global max_speed
    persistent keeping_ball
    
    if isempty(keeping_ball)
        keeping_ball = 0;    
    end
    
    toballvec = norm(ball.z - position);

    if toballvec < 450
        max_speed = toballvec / 20 + 10;    %low speed if robot near the ball
    end
    
    vec1 = ball.z - goal;
    nvec1 = norm(vec1);
    vec1 = vec1 / nvec1 * (nvec1 + 150);
    nvec1 = nvec1 + 150;
    vvec = position - ball.z;
    
    dist1 = dot(vvec, vec1/nvec1);                   %vertical   offset (looking away from the ball towards the goal)
    dist2 = dot(vvec, [vec1(2), -vec1(1)]/nvec1);    %horizontal offset
    
%     disp('position');
%     disp(position);
%     disp('ball.z');
%     disp(ball.z);
    
    
    if dist1 > -75 && dist1 < 325 && abs(dist2) < 25 || (keeping_ball == 1 && ball.I == 0)    %robot control the ball
        target_to_kick = ball.z + (vec1 / nvec1 * 50);
        keeping_ball = 1;
        
        if norm(position - goal) < 1500
            max_speed = 15;
        end
        
        disp('kick');
    elseif norm(ball.z - position) < 200    %robot near the ball
        vec3 = (position - ball.z);
        
        vecc = vec1 + goal;
        
        A = ball.y - vecc(2);
        B = (ball.x - vecc(1)) * -1;
        C = - A * vecc(1) - B * vecc(2);

        d = (A * position(1) + B * position(2) + C)/norm([A, B]);
        
        if d > 0
            vec4 = [vec3(2), -vec3(1)];
        else
            vec4 = [-vec3(2), vec3(1)];
        end
        
        vec4 = vec4 / norm(vec4) * abs(d / 0.2);
        
        target_to_kick = position + vec4;
        
        keeping_ball = 0;
        
        disp('near ball');
    else    %robot goes to the ball
        
        tar_vec = (ball.z - goal) / norm(ball.z - goal) * 150;
        kick_targ = tangent_solo(ball.z, 100, ball.z +  tar_vec, position);
        
        if (kick_targ(1) ~= 0)
            target_to_kick = kick_targ;
        else
            target_to_kick = ball.z + tar_vec;
        end
        
        keeping_ball = 0;
        
        disp('go to ball');
    end
end