import Flightschool

-- 핵심 정리의 의존 공리를 출력하여 검증 기록에서 확인합니다.
#print axioms Flightschool.interpreter_matches_direct
#print axioms Flightschool.initial_inv
#print axioms Flightschool.action_preserves
#print axioms Flightschool.step_preserves
#print axioms Flightschool.run_preserves
#print axioms Flightschool.history_preserves
#print axioms Flightschool.timeout_local
#print axioms Flightschool.old_data_local
#print axioms Flightschool.no_false_confirmation
#print axioms Flightschool.no_receiver_overrun
#print axioms Flightschool.repeated_loss
#print axioms Projects.StopAndWait.bad_unreachable
